import importlib
import json
import os
import sys
import unittest
from pathlib import Path
from unittest.mock import patch

import httpx
from fastapi.testclient import TestClient

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'wan-vace-bundle'))
SCRIPT = json.loads((ROOT / 'flows/unbox/unbox_perfume.json').read_text(encoding='utf-8'))
KEY = {'X-API-Key': 'test-worker-key'}
PID = '12345678-1234-4234-8234-123456789012'


def fake_object_info(canvas):
    """Every widget as a STRING input: checks graph structure (links, subgraphs), not real node schemas."""
    nodes = canvas['nodes'] + [n for s in canvas['definitions']['subgraphs'] for n in s['nodes']]
    width = {}
    for n in nodes:
        width[n['type']] = max(width.get(n['type'], 0), len(n.get('widgets_values') or []))
    return {t: {'input': {'required': {f'w{i}': ['STRING'] for i in range(k)}}} for t, k in width.items()}


class VaceApiTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        with patch.dict(os.environ, {'API_KEY': 'test-worker-key'}):
            cls.api = importlib.import_module('vace_api')

    def client(self, respond):
        original = httpx.AsyncClient

        def make(*args, **kwargs):
            kwargs['transport'] = httpx.MockTransport(respond)
            return original(*args, **kwargs)
        return patch.object(self.api.httpx, 'AsyncClient', make)

    def test_auth_and_bad_script(self):
        with TestClient(self.api.app) as c:
            self.assertEqual(c.get('/health').status_code, 401)
            self.assertEqual(c.post('/api/v1/generate_video', content=b'x').status_code, 401)
            r = c.post('/api/v1/generate_video', headers=KEY, data={'script_json': json.dumps({'segments': []})},
                       files={'reference_image': ('p.png', b'img', 'image/png')})
            self.assertEqual(r.status_code, 422)
            r = c.post('/api/v1/generate_video', headers=KEY, data={'script_json': json.dumps(SCRIPT)},
                       files={'reference_image': ('p.gif', b'img', 'image/gif')})
            self.assertEqual(r.status_code, 422)
            self.assertEqual(c.get('/api/v1/media', headers=KEY, params={'filename': '../x'}).status_code, 400)

    def test_submit_compiles_real_flow_with_uploaded_names(self):
        canvas = self.api.build_canvas(dict(SCRIPT))
        info, seen = fake_object_info(canvas), []

        def respond(request):
            seen.append(request.url.path)
            if request.url.path == '/upload/image':
                return httpx.Response(200, json={'name': f'up{len(seen)}.png'})
            if request.url.path == '/object_info':
                return httpx.Response(200, json=info)
            if request.url.path == '/prompt':
                graph = json.loads(request.content)['prompt']
                types = [n['class_type'] for n in graph.values()]
                self.assertIn('WanVaceToVideo', types)
                self.assertTrue(all(':' not in n['class_type'] for n in graph.values()))   # subgraph expanded
                loads = [n['inputs']['w0'] for n in graph.values() if n['class_type'] == 'LoadImage']
                self.assertEqual(set(loads), {'up1.png'})   # only the uploaded product photo, never the script name
                saves = [n['inputs']['w0'] for n in graph.values() if n['class_type'] == 'SaveVideo']
                self.assertEqual(len(saves), 1)
                self.assertTrue(saves[0].startswith('video/vace_'))
                return httpx.Response(200, json={'prompt_id': PID})
            raise AssertionError(request.url.path)
        with self.client(respond), TestClient(self.api.app) as c:
            r = c.post('/api/v1/generate_video', headers=KEY, data={'script_json': json.dumps(SCRIPT)},
                       files={'reference_image': ('p.png', b'img', 'image/png')})
        self.assertEqual(r.status_code, 200, r.text)
        self.assertEqual(r.json()['status_path'], f'/api/v1/jobs/{PID}')
        self.assertEqual(seen, ['/upload/image', '/object_info', '/prompt'])

    def test_job_complete_lists_video(self):
        def respond(request):
            return httpx.Response(200, json={PID: {'status': {'completed': True, 'status_str': 'success'},
                'outputs': {'9': {'images': [{'filename': 'vace_1.mp4', 'subfolder': 'video', 'type': 'output'}]}}}})
        with self.client(respond), TestClient(self.api.app) as c:
            r = c.get(f'/api/v1/jobs/{PID}', headers=KEY)
        self.assertEqual(r.json()['status'], 'complete')
        self.assertEqual(r.json()['videos'][0]['filename'], 'vace_1.mp4')


if __name__ == '__main__':
    unittest.main()
