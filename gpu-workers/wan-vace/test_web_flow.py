"""End-to-end test of the 20 s product video, the same path the web uses: AI service -> Claude director -> Vast VACE worker.

  python test_web_flow.py <product image> "<brief>" [9:16|16:9] [person image]

Starts a REAL Claude call and a REAL GPU render on the rented VM. Reads INTERNAL_SERVICE_KEY from the AI service .env
(never printed). Polls until the MP4 URL is ready (about 10-20 min).
"""
import base64
import json
import mimetypes
import sys
import time
import urllib.request
from pathlib import Path

AI = 'http://127.0.0.1:8082/api/v1/ai/video'
ENV = Path(__file__).resolve().parents[3] / 'brandhub-ai-service/.env'


def key():
    lines = [l.split('=', 1)[1].strip() for l in ENV.read_text(encoding='utf-8').splitlines()
             if l.startswith('INTERNAL_SERVICE_KEY=')]
    return lines[-1]   # last one wins, like python-dotenv


def data_url(path):
    mime = mimetypes.guess_type(path)[0] or 'image/png'
    return f'data:{mime};base64,' + base64.b64encode(Path(path).read_bytes()).decode()


def call(url, body=None):
    req = urllib.request.Request(url, data=json.dumps(body).encode() if body else None, method='POST' if body else 'GET',
                                 headers={'X-Internal-Key': key(), 'Content-Type': 'application/json'})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)


if __name__ == '__main__':
    image, brief = sys.argv[1], sys.argv[2]
    aspect = sys.argv[3] if len(sys.argv) > 3 else '9:16'
    body = {'prompt': brief, 'client_id': 'vace-test', 'reference_image_base64': data_url(image),
            'duration_seconds': 20, 'aspect_ratio': aspect}
    if len(sys.argv) > 4:
        body['character_image_base64'] = data_url(sys.argv[4])
    job = call(AI + '/generate', body)['job_id']
    print('job', job, flush=True)
    while True:
        time.sleep(15)
        s = call(f'{AI}/{job}/status')
        print(time.strftime('%H:%M:%S'), s['status'], flush=True)
        if s['status'] in ('COMPLETED', 'FAILED', 'SUBMISSION_UNKNOWN'):
            print(json.dumps({k: s.get(k) for k in ('video_url', 'error_code', 'error_message')}, ensure_ascii=False, indent=2))
            break
