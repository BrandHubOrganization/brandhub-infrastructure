import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EX = ROOT / 'flows/unbox'


def load_builder():
    spec = importlib.util.spec_from_file_location('build_vace_flow', ROOT / 'build_vace_flow.py')
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


class VaceFlowTest(unittest.TestCase):
    def build(self, name):
        b = load_builder()
        return b, b.build_canvas(json.loads((EX / f'unbox_{name}.json').read_text(encoding='utf-8')))

    def test_segments_are_chained_and_pinned(self):
        for name, ends in (('sneaker', [1, 2, 3, 0]), ('perfume', [1, 2, 3, None])):
            b, g = self.build(name)
            nodes = {n['id']: n for n in g['nodes']}
            src = {(l[3], l[4]): l[1] for l in g['links']}
            vaces = [n for n in g['nodes'] if n['type'] == 'WanVaceToVideo']
            self.assertEqual(len(vaces), 4)
            self.assertEqual(len(g['groups']), 4)
            for i, v in enumerate(vaces):
                self.assertTrue(all(inp['link'] for inp in v['inputs']), v['title'])   # incl. reference image
                self.assertEqual(v['widgets_values'][:3], [576, 1024, b.LENGTH])
                video = nodes[src[(v['id'], 3)]]                                    # control video
                if ends[i] is None:
                    self.assertEqual(video['title'], 'Control video')
                    grey = nodes[src[(video['id'], 1)]]
                    self.assertEqual(grey['widgets_values'][2], b.LENGTH - b.OVERLAP)
                else:
                    self.assertEqual(nodes[src[(video['id'], 1)]]['title'], f'K{ends[i]} = panel {ends[i] + 1}')
                    head = nodes[src[(video['id'], 0)]]
                    start = nodes[src[(head['id'], 0)]]
                    n_start = 1 if i == 0 else b.OVERLAP
                    if i == 0:
                        self.assertEqual(start['title'], 'K0 = panel 1')
                    else:   # starts on the previous segment's last OVERLAP frames
                        self.assertEqual(start['widgets_values'], [b.LENGTH - b.OVERLAP, b.OVERLAP])
                    self.assertEqual(nodes[src[(head['id'], 1)]]['widgets_values'][2], b.LENGTH - n_start - 1)
            cv = next(n for n in g['nodes'] if n['type'] == 'CreateVideo')
            self.assertIn('316 frames', cv['title'])

    def test_tvc_hard_cuts_landscape(self):
        b = load_builder()
        g = b.build_canvas(json.loads((ROOT / 'flows/tvc/tvc_tumbler.json').read_text(encoding='utf-8')))
        nodes = {n['id']: n for n in g['nodes']}
        src = {(l[3], l[4]): l[1] for l in g['links']}
        vaces = [n for n in g['nodes'] if n['type'] == 'WanVaceToVideo']
        self.assertEqual([v['widgets_values'][:2] for v in vaces], [[1024, 576]] * 6)
        for i, v in enumerate(vaces):   # every scene starts on its own panel (hard cut), never on overlap frames
            head = nodes[src[(v['id'], 3)]]
            head = nodes[src[(head['id'], 0)]] if head['title'].startswith('+ end') else head
            self.assertEqual(nodes[src[(head['id'], 0)]]['title'], f'K{i} = panel {i + 1}')
        self.assertFalse([n for n in g['nodes'] if n['type'] == 'ImageFromBatch'])
        self.assertIn('318 frames', next(n for n in g['nodes'] if n['type'] == 'CreateVideo')['title'])

    def test_ugc_presenter_feeds_every_chunk(self):
        spec = importlib.util.spec_from_file_location('build_ugc_flow', ROOT / 'build_ugc_flow.py')
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        g = mod.build(json.loads((ROOT / 'flows/ugc/ugc_sunscreen.json').read_text(encoding='utf-8')))
        scale = next(n for n in g['nodes'] if n['type'] == 'ImageScale')
        refs = [l for l in g['links'] if l[1] == scale['id']]
        self.assertEqual(len(refs), 5)   # 1 S2V + 3 extends + saved presenter photo
        self.assertFalse([n for n in g['nodes'] if n['pos'][1] >= mod.CUT_Y and n['type'] == 'KSampler'])

    def test_turnaround_feeds_every_storyboard(self):
        b = load_builder()
        for f in sorted((ROOT / 'flows').glob('*/*.json')):
            script = json.loads(f.read_text(encoding='utf-8'))
            if 'segments' not in script or f.name.endswith('_GUI.json'):
                continue
            g = b.build_canvas(script)
            src = {(l[3], l[4]): l[1] for l in g['links']}
            nodes = {n['id']: n for n in g['nodes']}
            turn = next(n for n in g['nodes'] if n['title'].startswith('Turnaround'))
            boards = [n for n in g['nodes'] if n['title'].startswith('Storyboard') and n['title'].endswith('(Qwen edit)')]
            for q in boards:
                self.assertEqual(nodes[src[(q['id'], 8)]]['title'], 'Turnaround 4 góc sản phẩm -> RGB', f.name)
                self.assertIn('Image 2 is a turnaround sheet', q['widgets_values'][1])

    def test_extra_image_feeds_storyboard_after_turnaround(self):
        b = load_builder()
        script = json.loads((ROOT / 'flows/fashion/fashion_dress.json').read_text(encoding='utf-8'))
        g = b.build_canvas({**script, 'extra_images': ['model.jpg']})
        nodes = {n['id']: n for n in g['nodes']}
        src = {(l[3], l[4]): l[1] for l in g['links']}
        q = next(n for n in g['nodes'] if n['title'].startswith('Storyboard') and n['title'].endswith('(Qwen edit)'))
        self.assertEqual(nodes[src[(q['id'], 9)]]['widgets_values'][0], 'model.jpg')   # image_3


if __name__ == '__main__':
    unittest.main()
