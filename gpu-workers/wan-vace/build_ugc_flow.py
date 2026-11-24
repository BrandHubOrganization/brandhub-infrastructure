"""Build a UGC talking-review flow (Wan 2.2 S2V 14B, lip-sync to a voice file) from a director script.

  python build_ugc_flow.py flows/ugc/ugc_sunscreen.json flows/ugc/S2V_ugc_sunscreen_GUI.json

Base: ComfyUI's official template video_wan2_2_14B_s2v.json (resources/s2v_template.json), lightning half only
(4 steps, cfg 1). Changes: the slow 20-step copy below it is removed; Qwen makes the presenter photo (a creator
holding the product) from the product photo and feeds it to every S2V chunk; prompt, size, voice file and output
name come from the script. Length: 3 chunks x 77 frames = 231 frames = 14.4 s at 16 fps; enable the bypassed
third "Video S2V Extend" for 4 chunks = 19.3 s. The voice file must be at least that long.
"""
import copy
import json
import sys
from pathlib import Path

RES = Path(__file__).resolve().parent / 'wan-vace-bundle/resources'
CUT_Y = 1600          # template: lightning flow above this y, the 20-step duplicate below it


def build(script):
    g = json.loads((RES / 's2v_template.json').read_text(encoding='utf-8'))
    qwen = json.loads((RES / 'qwen_template.json').read_text(encoding='utf-8'))
    W, H = script.get('size', [576, 1024])
    drop = {n['id'] for n in g['nodes'] if n['pos'][1] >= CUT_Y}
    g['nodes'] = [n for n in g['nodes'] if n['id'] not in drop]
    gone = {L[0] for L in g['links'] if L[1] in drop or L[3] in drop}
    assert all(L[1] not in drop and L[3] not in drop for L in g['links'] if L[0] not in gone)
    g['links'] = [L for L in g['links'] if L[0] not in gone]
    g['groups'] = [x for x in g['groups'] if x['bounding'][1] < CUT_Y]
    used = {n['type'] for n in g['nodes']}
    g['definitions']['subgraphs'] = [s for s in g['definitions']['subgraphs'] if s['id'] in used] + [qwen['subgraph']]
    N = {n['id']: n for n in g['nodes']}

    def kind(t):
        return [n for n in g['nodes'] if n['type'] == t]

    prod = N[52]                                   # LoadImage: now the product photo
    prod['title'] = 'SẢN PHẨM - upload ảnh sản phẩm'
    prod['widgets_values'][0] = script['product_image']
    audio, = kind('LoadAudio')
    audio['title'] = 'GIỌNG ĐỌC - upload file voice (>= 20 s)'
    audio['widgets_values'][0] = script['voice_audio']
    s2v, = kind('WanSoundImageToVideo')
    s2v['widgets_values'][:2] = [W, H]
    pos = next(n for n in kind('CLIPTextEncode') if 'Positive' in n.get('title', ''))
    pos['title'], pos['widgets_values'][0] = 'PROMPT (người nói)', script['prompt']
    save, = kind('SaveVideo')
    save['widgets_values'][0] = f"video/S2V_{script['name']}"
    chunks = int(script.get('chunks', 3))   # template: base chunk + 3 "Video S2V Extend" (the last one bypassed)
    ext = sorted((n for n in g['nodes'] if n['type'] in used and any(
        s['id'] == n['type'] and s['name'] == 'Video S2V Extend' for s in g['definitions']['subgraphs'])),
        key=lambda n: n['pos'][0])
    if not 1 <= chunks <= len(ext) + 1:
        raise ValueError(f'chunks must be 1..{len(ext) + 1}')
    for k, n in enumerate(ext):
        n['mode'] = 0 if k < chunks - 1 else 4
    next(n for n in kind('PrimitiveInt') if n.get('title') == 'Batch sizes')['widgets_values'][0] = chunks
    ks, = kind('KSampler')
    ks['widgets_values'][0], ks['widgets_values'][1] = int(script.get('seed', 20261119)), 'fixed'

    nid = [max(N) + 1]
    lid = [max(L[0] for L in g['links']) + 1]

    def add(node):
        node.update(id=nid[0], order=nid[0])
        nid[0] += 1
        g['nodes'].append(node)
        N[node['id']] = node
        return node

    def link(src, dst, slot):
        typ = src['outputs'][0]['type']
        L = [lid[0], src['id'], 0, dst['id'], slot, typ]
        lid[0] += 1
        g['links'].append(L)
        src['outputs'][0]['links'] = (src['outputs'][0].get('links') or []) + [L[0]]
        dst['inputs'][slot]['link'] = L[0]

    q = copy.deepcopy(qwen['node'])
    q.pop('widgets_values_named', None)
    q.update(title='Ảnh người review cầm sản phẩm (Qwen edit)', pos=[-520, 940])
    q['widgets_values'][1], q['widgets_values'][11] = script['presenter_prompt'], int(script.get('seed', 20261119))
    q['widgets_values'][7:10] = [True, W, H]
    for i in q['inputs']:
        i['link'] = None
    q['outputs'][0]['links'] = []
    add(q)
    rgb = add({'type': 'SplitImageWithAlpha', 'title': 'Presenter -> RGB', 'pos': [-520, 1460], 'size': [300, 60],
               'flags': {}, 'mode': 0, 'inputs': [{'name': 'image', 'type': 'IMAGE', 'link': None}],
               'outputs': [{'name': 'IMAGE', 'type': 'IMAGE', 'links': []}, {'name': 'MASK', 'type': 'MASK', 'links': []}],
               'properties': {'Node name for S&R': 'SplitImageWithAlpha'}, 'widgets_values': []})
    scale = add({'type': 'ImageScale', 'title': f'Presenter {W}x{H} (ref_image)', 'pos': [-200, 1460],
                 'size': [300, 130], 'flags': {}, 'mode': 0,
                 'inputs': [{'name': 'image', 'type': 'IMAGE', 'link': None}],
                 'outputs': [{'name': 'IMAGE', 'type': 'IMAGE', 'links': []}],
                 'properties': {'Node name for S&R': 'ImageScale'}, 'widgets_values': ['lanczos', W, H, 'center']})
    old = list(prod['outputs'][0]['links'])         # product -> every ref_image; reroute through the presenter photo
    prod['outputs'][0]['links'] = []
    for L in g['links']:
        if L[0] in old:
            L[1] = scale['id']
            scale['outputs'][0]['links'].append(L[0])
    link(prod, q, 7)
    link(q, rgb, 0)
    link(rgb, scale, 0)
    save_ref = add({'type': 'SaveImage', 'title': 'Saved presenter photo', 'pos': [-200, 1620], 'size': [300, 380],
                    'flags': {}, 'mode': 0, 'inputs': [{'name': 'images', 'type': 'IMAGE', 'link': None}],
                    'outputs': [], 'properties': {'Node name for S&R': 'SaveImage'},
                    'widgets_values': ['video/presenter']})
    link(scale, save_ref, 0)

    g['last_node_id'], g['last_link_id'] = nid[0] - 1, lid[0] - 1
    for L in g['links']:   # self-check: both ends of every link agree
        src, dst = N[L[1]], N[L[3]]
        assert dst['inputs'][L[4]]['link'] == L[0] and L[0] in (src['outputs'][L[2]]['links'] or []), L
    return g


if __name__ == '__main__':
    src, out = sys.argv[1:3]
    graph = build(json.loads(Path(src).read_text(encoding='utf-8')))
    Path(out).write_text(json.dumps(graph, ensure_ascii=False, indent=2), encoding='utf-8')
    print('wrote', out, len(graph['nodes']), 'nodes')
