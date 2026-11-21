"""Compile this bundle's GUI graphs using the target ComfyUI's widget schemas."""
import copy

MISSING = object()
PRIMITIVES = {'INT', 'FLOAT', 'BOOLEAN', 'STRING', 'COMBO'}


def _fields(inputs):
    for group in ('required', 'optional'):
        yield from inputs.get(group, {}).items()


def _widget_inputs(node, info):
    values = iter(node.get('widgets_values') or [])
    result = {}
    def visit(fields, prefix=''):
        for name, spec in _fields(fields):
            kind, options = spec[0], spec[1] if len(spec) > 1 else {}
            # UI-hidden compatibility widgets (SaveVideo.codec) still serialize.
            # Server-injected inputs live in the separate hidden schema group.
            if options.get('forceInput'):
                continue
            key = prefix + name
            combo = isinstance(kind, str) and 'DYNAMICCOMBO' in kind
            if not (isinstance(kind, list) or isinstance(kind, str) and (set(kind.split(',')) <= PRIMITIVES or combo)):
                continue
            value = next(values, MISSING)
            if value is MISSING:
                continue
            result[key] = value
            if options.get('control_after_generate'):
                control = next(values, MISSING)
                if control not in ('fixed', 'increment', 'decrement', 'randomize'):
                    raise ValueError(f'Unsupported seed serialization: {node["type"]}')
            if combo:
                option = next((o for o in options.get('options', []) if o['key'] == value), None)
                if option is None:
                    raise ValueError(f'Unsupported dynamic option: {node["type"]}.{key}')
                visit(option.get('inputs', {}), key + '.')
    visit(info.get('input', {}))
    remaining = list(values)
    if remaining and not (node['type'] == 'LoadImage' and remaining == ['image']):
        raise ValueError(f'Unsupported widget serialization: {node["type"]} ({len(remaining)} extra values)')
    return result


def canvas_to_api(canvas, object_info):
    definitions = {s['id']: s for s in canvas.get('definitions', {}).get('subgraphs', [])}
    result, scopes, active = {}, {}, set()

    def scope(graph, prefix='', bindings=()):
        nodes = {n['id']: n for n in graph['nodes']}
        links = {}
        for link in graph.get('links', []):
            if isinstance(link, list):
                lid, origin, slot, target, target_slot = link[:5]
                link = dict(id=lid, origin_id=origin, origin_slot=slot, target_id=target, target_slot=target_slot)
            links[link['id']] = link
        return graph, prefix, bindings, nodes, links

    def linked(ctx, lid):
        if lid not in ctx[4]:
            raise ValueError(f'Missing graph link: {lid}')
        edge = ctx[4][lid]
        if edge['origin_id'] == -10:
            return ctx[2][edge['origin_slot']]
        return resolve(ctx, edge['origin_id'], edge['origin_slot'])

    def expand(ctx, node):
        key = ctx[1] + str(node['id'])
        if key not in scopes:
            sg = definitions[node['type']]
            ports = {i['name']: i for i in node.get('inputs', [])}
            values, bindings = iter(node.get('widgets_values') or []), []
            for port in sg.get('inputs', []):
                kind = port.get('type')
                value = next(values, MISSING) if kind in PRIMITIVES else MISSING
                edge = ports.get(port['name'], {}).get('link')
                bindings.append(linked(ctx, edge) if edge is not None else value)
            if list(values):
                raise ValueError(f'Extra subgraph widgets: {key}')
            scopes[key] = scope(sg, key + ':', bindings)
        return scopes[key]

    def resolve(ctx, nid, slot):
        node = ctx[3].get(nid)
        if node is None:
            raise ValueError(f'Missing node: {nid}')
        key = ctx[1] + str(nid)
        if node.get('mode') == 2:
            return MISSING
        if node.get('mode') == 4:
            marker = 'bypass:' + key
            if marker in active:
                raise ValueError('Workflow contains a bypass cycle')
            active.add(marker)
            try:
                output_type = node.get('outputs', [])[slot]['type']
                candidates = [i for i in node.get('inputs', [])
                              if i.get('link') is not None and i.get('type') == output_type]
                if not candidates:
                    raise ValueError(f'Cannot resolve bypassed node: {key}')
                return linked(ctx, candidates[0]['link'])
            finally:
                active.remove(marker)
        if node['type'] in definitions:
            sub = expand(ctx, node)
            edges = [l for l in sub[4].values() if l['target_id'] == -20 and l['target_slot'] == slot]
            if len(edges) != 1:
                raise ValueError(f'Ambiguous subgraph output: {key}:{slot}')
            return linked(sub, edges[0]['id'])
        build(ctx, node)
        return [key, slot]

    def build(ctx, node):
        key = ctx[1] + str(node['id'])
        if key in result:
            return
        if key in active:
            raise ValueError('Workflow contains a cycle')
        active.add(key)
        cls = node['type']
        if cls not in object_info:
            raise ValueError(f'Missing ComfyUI node: {cls}')
        if node.get('mode', 0) != 0:
            raise ValueError(f'Unsupported muted/bypassed execution node: {key}')
        inputs = _widget_inputs(node, object_info[cls])
        for port in node.get('inputs', []):
            if port.get('link') is not None:
                value = linked(ctx, port['link'])
                if value is MISSING:
                    inputs.pop(port['name'], None)
                else:
                    inputs[port['name']] = value
        result[key] = {'class_type': cls, 'inputs': inputs, '_meta': {'title': node.get('title', cls)}}
        active.remove(key)

    top = scope(copy.deepcopy(canvas))
    outputs = [n for n in top[3].values() if n['type'] in ('SaveVideo', 'SaveImage') and n.get('mode', 0) == 0]
    for node in outputs or list(top[3].values()):
        build(top, node)
    return result
