"""Build a ComfyUI canvas flow (Wan 2.2 Fun VACE 14B) from a director script.

  python build_vace_flow.py wan_vace_bundle/director/examples/sneaker_pov_20s.json wan_vace_bundle/WanVACE_Sneaker_20s_GUI.json

Shape (the director only fills text):
  storyboard  one 2x2 Qwen grid per entry of `storyboard_prompts` (or one `storyboard_prompt`) -> panels K0, K1, ...
              each panel has the video size (`size`, default 576x1024)
  reference   the product photo, padded white to the video size: VACE's identity anchor in EVERY segment
  segments    any number x 85 frames at 16 fps (5.3 s). `start` picks the first frames:
                "prev"  (default after segment 1) the LAST 8 FRAMES of the previous segment, joined with that overlap
                n       panel Kn (default for segment 1); a hard cut when it is not segment 1
                "free"  nothing pinned
              each segment ends on its `end_panel` or runs free when end_panel is null
  sampling    Wan 2.2 MoE: high-noise model steps 0-4, low-noise model steps 4-8, lightx2v 4-step LoRAs, cfg 1
No audio: Wan VACE makes silent video.
"""
import copy
import json
import sys
import uuid
from pathlib import Path

HERE = Path(__file__).resolve().parent
BUNDLE = HERE / 'wan_vace_bundle'
LENGTH, OVERLAP, FPS = 85, 8, 16
STEPS, SPLIT = 8, 4       # lightx2v: 4 high-noise + 4 low-noise steps at cfg 1
NEG = ('色调艳丽，过曝，静态，细节模糊不清，字幕，风格，作品，画作，画面，静止，整体发灰，最差质量，低质量，JPEG压缩残留，丑陋的，'
       '残缺的，多余的手指，画得不好的手部，画得不好的脸部，畸形的，毁容的，形态畸形的肢体，手指融合，静止不动的画面，杂乱的背景，'
       '三条腿，背景人多，倒着走，塑料质感，蜡像质感，磨皮，CG渲染，3D渲染，过度锐化，过度完美，'
       'plastic skin, waxy, airbrushed, CGI, 3D render, oversharpened, too perfect, glossy stock photo')
TURN = ('Image 1 is the product photo: use exactly this {product}, its shape, proportions, materials, colours, logos '
        'and printed text. Create ONE product turnaround reference sheet: a 2x2 grid of four equal square panels, edge '
        'to edge, no borders, no text and no numbers; in every panel the same single {product} alone, centred, the '
        'same size, on a plain pure white background in soft even studio light, photorealistic. Panel 1 (top left): '
        '{0}. Panel 2 (top right): {1}. Panel 3 (bottom left): {2}. Panel 4 (bottom right): {3}. Keep every detail '
        'consistent between the four views; draw the hidden sides as they really are on this product.')
TURN_HINT = ('Image 2 is a turnaround sheet of this same product seen from four sides: use it to draw every side of the '
             'product correctly when it turns.')
MODELS = {'high': 'wan2.2_fun_vace_high_noise_14B_fp8_scaled.safetensors',
          'low': 'wan2.2_fun_vace_low_noise_14B_fp8_scaled.safetensors',
          'lora_high': 'wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors',
          'lora_low': 'wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors',
          'clip': 'umt5_xxl_fp8_e4m3fn_scaled.safetensors', 'vae': 'wan_2.1_vae.safetensors'}


def build_canvas(script):
    segs = script['segments']
    W, H = script.get('size', [576, 1024])   # one storyboard panel has the video size, so pins are not upscaled
    if W % 16 or H % 16:
        raise ValueError('size must be divisible by 16')
    boards = script.get('storyboard_prompts') or [script['storyboard_prompt']]
    n_panels = 4 * len(boards)
    starts = [s.get('start', 0 if i == 0 else 'prev') for i, s in enumerate(segs)]
    if not segs or starts[0] == 'prev':
        raise ValueError('need at least one segment; segment 1 cannot start on "prev"')
    for st, s in zip(starts, segs):
        if st not in ('prev', 'free') and st not in range(n_panels) or s.get('end_panel') not in [*range(n_panels), None]:
            raise ValueError(f'start must be "prev", "free" or 0..{n_panels - 1}; end_panel 0..{n_panels - 1} or null')
    seed = int(script.get('seed', 20261113))
    qwen = json.loads((BUNDLE / 'resources/qwen_template.json').read_text(encoding='utf-8'))
    g = {'id': str(uuid.uuid5(uuid.NAMESPACE_URL, json.dumps(script, sort_keys=True))), 'revision': 0,
         'last_node_id': 0, 'last_link_id': 0, 'nodes': [], 'links': [], 'groups': [], 'config': {},
         'extra': {'ds': {'scale': 0.3, 'offset': [600, 300]}}, 'version': 0.4,
         'definitions': {'subgraphs': [qwen['subgraph']]}}
    top, lk, nid = {}, [0], [1000]

    def add(typ, title, pos, inputs, outputs, widgets, size=(300, 130), mode=0):
        nid[0] += 1
        n = {'id': nid[0], 'type': typ, 'title': title, 'pos': list(pos), 'size': list(size), 'flags': {},
             'order': nid[0], 'mode': mode,
             'inputs': [{'name': a, 'type': t, 'link': None} | ({'widget': {'name': a}} if w else {})
                        for a, t, *w in inputs],
             'outputs': [{'name': a, 'type': t, 'links': []} for a, t in outputs],
             'properties': {'Node name for S&R': typ}, 'widgets_values': widgets}
        g['nodes'].append(n)
        top[n['id']] = n
        return n['id']

    def link(s, ss, d, dslot):
        lk[0] += 1
        typ = top[s]['outputs'][ss]['type']
        g['links'].append([lk[0], s, ss, d, dslot, typ])
        top[s]['outputs'][ss]['links'].append(lk[0])
        top[d]['inputs'][dslot]['link'] = lk[0]

    IMG, MASK = [('IMAGE', 'IMAGE')], [('MASK', 'MASK')]

    def empty(n, color, pos, title):
        return add('EmptyImage', title, pos, [], IMG, [W, H, n, color])

    def batch(a, b, pos, title='Batch'):
        i = add('ImageBatch', title, pos, [('image1', 'IMAGE'), ('image2', 'IMAGE')], IMG, [])
        link(a, 0, i, 0)
        link(b, 0, i, 1)
        return i

    def from_batch(src, start, length, pos, title):
        i = add('ImageFromBatch', title, pos, [('image', 'IMAGE')], IMG, [start, length])
        link(src, 0, i, 0)
        return i

    # ---- inputs, storyboard, shared models -------------------------------------------------------------------
    prod = add('LoadImage', 'SẢN PHẨM - upload ảnh sản phẩm', (0, 0), [],
               [('IMAGE', 'IMAGE'), ('MASK', 'MASK')], [script.get('product_image', 'product.png'), 'image'], (320, 380))
    ref = add('ResizeAndPadImage', f'Ảnh tham chiếu VACE (nền trắng, {W}x{H})', (0, 430), [('image', 'IMAGE')], IMG,
              [W, H, 'white', 'lanczos'])
    link(prod, 0, ref, 0)

    def qwen_node(title, pos, prompt, sd, w, h, images):
        q = copy.deepcopy(qwen['node'])
        nid[0] += 1
        q.update(id=nid[0], title=title, pos=list(pos), order=nid[0])
        q.pop('widgets_values_named', None)
        q['widgets_values'][1], q['widgets_values'][11] = prompt, sd
        q['widgets_values'][7:10] = [True, w, h]
        for inp in q['inputs']:
            inp['link'] = None
        q['outputs'][0]['links'] = []
        g['nodes'].append(q)
        top[q['id']] = q
        for k, img in enumerate(images):   # image_1, image_2, ...
            link(img, 0, q['id'], 7 + k)
        rgb = add('SplitImageWithAlpha', f'{title.split(" (")[0]} -> RGB', (pos[0], pos[1] + 520), [('image', 'IMAGE')],
                  [('IMAGE', 'IMAGE'), ('MASK', 'MASK')], [])
        link(q['id'], 0, rgb, 0)
        return rgb

    # Turnaround: Qwen draws the product from 4 sides first; every storyboard sees it as image 2, so panels that show
    # a hidden side (back, sole, top) copy it instead of guessing. VACE keeps the clean photo as its one reference.
    views = script.get('views')
    sheet = None
    if views:
        if len(views) != 4:
            raise ValueError('views must list exactly 4 sides')
        sheet = qwen_node('Turnaround 4 góc sản phẩm (Qwen edit)', (400, -1100), TURN.format(
            *views, product=script.get('product_name', 'product')), seed + 99, 1024, 1024, [prod])
        save_t = add('SaveImage', 'Saved turnaround', (750, -1100), [('images', 'IMAGE')], [], ['video/turnaround'],
                     (300, 380))
        link(sheet, 0, save_t, 0)

    # extra storyboard references (e.g. a model photo for a lookbook): image 2.. after the product (and turnaround)
    extras = [add('LoadImage', f'ẢNH PHỤ {k + 1} - upload ({name})', (-400, 450 * k), [],
                  [('IMAGE', 'IMAGE'), ('MASK', 'MASK')], [name, 'image'], (320, 380))
              for k, name in enumerate(script.get('extra_images', []))]
    panels = []
    for b, prompt in enumerate(boards):
        by = 1100 * b
        if sheet:
            cut = prompt.index('. ') + 2   # right after "Image 1 is the product photo: ..."
            prompt = prompt[:cut] + TURN_HINT + ' ' + prompt[cut:]
        rgb = qwen_node(f'Storyboard {b + 1}: 2x2 = K{4 * b}..K{4 * b + 3} (Qwen edit)', (400, by), prompt, seed + b,
                        2 * W, 2 * H, [prod] + ([sheet] if sheet else []) + extras)
        sb = add('ImageScale', f'Storyboard -> {2 * W}x{2 * H}', (750, by + 520), [('image', 'IMAGE')], IMG,
                 ['lanczos', 2 * W, 2 * H, 'center'])
        link(rgb, 0, sb, 0)
        save_sb = add('SaveImage', 'Saved storyboard', (750, by), [('images', 'IMAGE')], [], ['video/storyboard'],
                      (300, 380))
        link(sb, 0, save_sb, 0)
        inset = 8   # skip a thin border the model may draw between panels; WanVaceToVideo rescales to W x H
        for i in range(4):
            c = add('ImageCrop', f'K{4 * b + i} = panel {4 * b + i + 1}', (1100 + 330 * i, by + 520),
                    [('image', 'IMAGE')], IMG, [W - 2 * inset, H - 2 * inset, (i % 2) * W + inset, (i // 2) * H + inset])
            link(sb, 0, c, 0)
            panels.append(c)

    my = 1100 * len(boards)
    unet = {k: add('UNETLoader', f'Wan 2.2 Fun VACE {k}-noise', (0, my + 200 * j), [], [('MODEL', 'MODEL')],
                   [MODELS[k], 'default']) for j, k in enumerate(('high', 'low'))}
    lora = {}
    for j, k in enumerate(('high', 'low')):
        lora[k] = add('LoraLoaderModelOnly', f'lightx2v 4-step LoRA ({k})', (350, my + 200 * j), [('model', 'MODEL')],
                      [('MODEL', 'MODEL')], [MODELS['lora_' + k], 1.0])
        link(unet[k], 0, lora[k], 0)
    shift = {}
    for j, k in enumerate(('high', 'low')):
        shift[k] = add('ModelSamplingSD3', f'Shift ({k})', (700, my + 200 * j), [('model', 'MODEL')],
                       [('MODEL', 'MODEL')], [8.0])
        link(lora[k], 0, shift[k], 0)
    clip = add('CLIPLoader', 'Text encoder (umt5)', (0, my + 400), [], [('CLIP', 'CLIP')], [MODELS['clip'], 'wan', 'default'])
    vae = add('VAELoader', 'Wan VAE', (0, my + 550), [], [('VAE', 'VAE')], [MODELS['vae']])
    neg = add('CLIPTextEncode', 'Negative (Wan default)', (350, my + 400), [('clip', 'CLIP')],
              [('CONDITIONING', 'CONDITIONING')], [NEG], (400, 200))
    link(clip, 0, neg, 0)

    # ---- segments -------------------------------------------------------------------------------------------------
    kept, prev, prev_len, t0, total = [], None, 0, 0.0, 0
    for i, seg in enumerate(segs):
        x, y = 1100, my + 900 * i
        st, end = starts[i], seg.get('end_panel')
        length = int(seg.get('frames', LENGTH))   # 4n+1; TVC shots are shorter than 85
        if (length - 1) % 4 or length < 2 * OVERLAP + 1:
            raise ValueError(f'segment {i + 1}: frames must be 4n+1 and at least {2 * OVERLAP + 1}')
        n_start = {'prev': OVERLAP, 'free': 0}.get(st, 1)
        n_free = length - n_start - (end is not None)
        n_new = length - OVERLAP if st == 'prev' else length
        total += n_new
        dur = n_new / FPS
        tag = f'NODE {i + 1} ({t0:.1f}-{t0 + dur:.1f} s)'
        how = {'prev': f'node {i} last {OVERLAP} frames', 'free': 'free'}.get(st, f'K{st}' + (' (CUT)' if i else ''))
        g['groups'].append({'id': i + 1, 'title': f'{tag}: starts on {how}'
                            f', ends {"on K" + str(end) if end is not None else "free"} - prompt ở ô đầu tiên',
                            'bounding': [x - 20, y - 60, 3050, 820], 'color': '#3f789e', 'font_size': 28, 'flags': {}})
        t0 += dur
        pos = add('CLIPTextEncode', f'{tag} PROMPT', (x, y), [('clip', 'CLIP')], [('CONDITIONING', 'CONDITIONING')],
                  [seg['prompt']], (420, 330))
        link(clip, 0, pos, 0)
        grey = empty(n_free, 0x808080, (x + 450, y + 400), f'{n_free} grey frames (VACE generates these)')
        m_gen = empty(n_free, 0xFFFFFF, (x + 450, y + 700), f'{n_free} white = generate')
        video, masks = grey, m_gen
        if n_start:
            start = (from_batch(prev, prev_len - OVERLAP, OVERLAP, (x, y + 400), f'Node {i} last {OVERLAP} frames')
                     if st == 'prev' else panels[st])
            video = batch(start, grey, (x + 800, y + 400), 'Control video')
            m_keep = empty(n_start, 0x000000, (x + 450, y + 560), f'{n_start} black = keep')
            masks = batch(m_keep, m_gen, (x + 800, y + 560), 'Mask frames')
        if end is not None:
            video = batch(video, panels[end], (x + 1100, y + 400), f'+ end frame K{end}')
            masks = batch(masks, add('EmptyImage', '1 black = keep', (x + 800, y + 700), [], IMG, [W, H, 1, 0]),
                          (x + 1100, y + 560), 'Mask frames + end')
        mask = add('ImageToMask', 'Mask', (x + 1100, y + 700), [('image', 'IMAGE')], MASK, ['red'])
        link(masks, 0, mask, 0)
        vace = add('WanVaceToVideo', f'{tag} VACE', (x + 450, y), [
            ('positive', 'CONDITIONING'), ('negative', 'CONDITIONING'), ('vae', 'VAE'), ('control_video', 'IMAGE'),
            ('control_masks', 'MASK'), ('reference_image', 'IMAGE')],
            [('positive', 'CONDITIONING'), ('negative', 'CONDITIONING'), ('latent', 'LATENT'), ('trim_latent', 'INT')],
            [W, H, length, 1, float(seg.get('strength', 1.0))], (320, 330))
        for slot, src in enumerate((pos, neg, vae, video, mask, ref)):
            link(src, 0, vace, slot)
        ks = []
        for j, k in enumerate(('high', 'low')):
            s = add('KSamplerAdvanced', f'Sampler {k}-noise', (x + 800 + 330 * j, y), [
                ('model', 'MODEL'), ('positive', 'CONDITIONING'), ('negative', 'CONDITIONING'), ('latent_image', 'LATENT')],
                [('LATENT', 'LATENT')],
                ['enable' if j == 0 else 'disable', seed + 10 + i, 'fixed', STEPS, 1.0, 'euler', 'simple',
                 0 if j == 0 else SPLIT, SPLIT if j == 0 else 10000, 'enable' if j == 0 else 'disable'], (310, 330))
            link(shift[k], 0, s, 0)
            link(vace, 0, s, 1)
            link(vace, 1, s, 2)
            link(vace if j == 0 else ks[0], 2 if j == 0 else 0, s, 3)
            ks.append(s)
        trim = add('TrimVideoLatent', 'Drop reference frame', (x + 1460, y), [('samples', 'LATENT'),
                   ('trim_amount', 'INT', True)], [('LATENT', 'LATENT')], [0])
        link(ks[1], 0, trim, 0)
        link(vace, 3, trim, 1)
        dec = add('VAEDecode', f'{tag} frames', (x + 1460, y + 180), [('samples', 'LATENT'), ('vae', 'VAE')], IMG, [])
        link(trim, 0, dec, 0)
        link(vae, 0, dec, 1)
        kept.append(dec if st != 'prev' else from_batch(dec, OVERLAP, length - OVERLAP, (x + 1460, y + 330),
                                                         f'Node {i + 1} without the {OVERLAP} shared frames'))
        prev, prev_len = dec, length

    # ---- join + save ---------------------------------------------------------------------------------------------
    jx, jy = 4300, my
    video = kept[0]
    for i, k in enumerate(kept[1:]):
        video = batch(video, k, (jx, jy + 150 * i), f'Join node {i + 2}')
    cv = add('CreateVideo', f'~{total / FPS:.1f} s video ({total} frames, {FPS} fps, no sound)', (jx + 350, jy),
             [('images', 'IMAGE'), ('audio', 'AUDIO')], [('VIDEO', 'VIDEO')], [FPS, 8, 'sRGB', '420', 'none'])
    link(video, 0, cv, 0)
    sv = add('SaveVideo', 'Save video', (jx + 700, jy), [('video', 'VIDEO')], [],
             [f"video/WanVACE_{script.get('name', 'product')}_{round(total / FPS)}s", 'auto', 'auto', 'auto'], (400, 500))
    link(cv, 0, sv, 0)
    g['last_node_id'], g['last_link_id'] = nid[0], lk[0]
    for L in g['links']:   # self-check: both ends of every link agree
        assert top[L[3]]['inputs'][L[4]]['link'] == L[0] and L[0] in top[L[1]]['outputs'][L[2]]['links'], L
    return g


if __name__ == '__main__':
    src, out = sys.argv[1:3]
    graph = build_canvas(json.loads(Path(src).read_text(encoding='utf-8')))
    Path(out).write_text(json.dumps(graph, ensure_ascii=False, indent=2), encoding='utf-8')
    print('wrote', out, len(graph['nodes']), 'nodes')
