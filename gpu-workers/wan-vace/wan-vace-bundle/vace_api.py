"""Authenticated Wan VACE product-video worker (same contract as the LTX / Animate workers).

POST /api/v1/generate_video  reference_image (product photo) + script_json (a flows/<genre>/*.json director script)
                             + optional extra_images -> {prompt_id, status_path}
GET  /api/v1/jobs/{id}       pending | running | complete | failed | unknown, with media download paths
GET  /api/v1/media           download one output file
Every route needs the X-API-Key header. Run behind ComfyUI on COMFY_URL; start with start_api.py.
"""
import copy
import hmac
import json
import os
import secrets
import sys
import tempfile
import uuid
from pathlib import Path, PurePosixPath
from typing import List, Optional
from urllib.parse import urlencode

import httpx
from fastapi import Depends, FastAPI, File, Form, Header, HTTPException, UploadFile
from fastapi.responses import JSONResponse, Response

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT.parent))   # build_vace_flow.py sits next to the wan-vace-bundle folder

from build_vace_flow import FPS, build_canvas  # noqa: E402
from canvas_api import canvas_to_api  # noqa: E402

COMFY = os.getenv('COMFY_URL', 'http://127.0.0.1:10101').rstrip('/')
VIDEO_SUFFIXES = {'.mp4', '.webm', '.mov', '.mkv'}
IMAGE_TYPES = {'image/png': '.png', 'image/jpeg': '.jpg', 'image/webp': '.webp'}
MAX_IMAGE = 20 * 1024 * 1024
MAX_EXTRA, MAX_SEGMENTS, MAX_BOARDS, MAX_SIDE = 3, 8, 2, 1280
MAX_REQUEST_BYTES = (1 + MAX_EXTRA) * MAX_IMAGE + 1024 * 1024   # images + script/multipart overhead


def load_api_key():
    configured = os.getenv('API_KEY', '').strip()
    if configured:
        return configured
    path = Path(os.getenv('API_KEY_FILE', str(ROOT / '.api_key')))
    path.parent.mkdir(parents=True, exist_ok=True)
    # Publish a fully written key atomically; simultaneous workers share it.
    fd, temporary = tempfile.mkstemp(prefix='.key-', dir=path.parent)
    try:
        with os.fdopen(fd, 'w', encoding='utf-8') as f:
            f.write(secrets.token_urlsafe(32) + '\n')
        try:
            os.link(temporary, path)
        except FileExistsError:
            pass
    finally:
        os.unlink(temporary)
    os.chmod(path, 0o600)
    key = path.read_text(encoding='utf-8').strip()
    if not key:
        raise RuntimeError('API key file is empty')
    return key


API_KEY = load_api_key()


class RequestGuard:
    """Authenticate and bound upload bytes before FastAPI spools multipart files."""
    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        if scope['type'] != 'http':
            return await self.app(scope, receive, send)
        path = scope.get('path', '')
        headers = dict(scope.get('headers', []))
        if path == '/health' or path.startswith('/api/v1/'):
            if not hmac.compare_digest(headers.get(b'x-api-key', b''), API_KEY.encode()):
                return await JSONResponse({'detail': 'Invalid API key'}, status_code=401)(scope, receive, send)
        if path == '/api/v1/generate_video' and scope['method'] == 'POST':
            try:
                length = int(headers.get(b'content-length', b'0'))
                if length < 0:
                    raise ValueError
            except ValueError:
                return await JSONResponse({'detail': 'Invalid Content-Length'}, status_code=400)(scope, receive, send)
            if length > MAX_REQUEST_BYTES:
                return await JSONResponse({'detail': 'Upload request too large'}, status_code=413)(scope, receive, send)
            chunks, total = [], 0
            while True:
                message = await receive()
                if message['type'] == 'http.disconnect':
                    return
                chunk = message.get('body', b'')
                total += len(chunk)
                if total > MAX_REQUEST_BYTES:
                    return await JSONResponse({'detail': 'Upload request too large'}, status_code=413)(scope, receive, send)
                chunks.append(chunk)
                if not message.get('more_body', False):
                    break
            body = b''.join(chunks)
            sent = False
            upstream_receive = receive

            async def replay():
                nonlocal sent
                if not sent:
                    sent = True
                    return {'type': 'http.request', 'body': body, 'more_body': False}
                return await upstream_receive()
            receive = replay
        return await self.app(scope, receive, send)


app = FastAPI(title='Wan VACE Product Video', version='1.0.0')
app.add_middleware(RequestGuard)


async def auth(x_api_key: Optional[str] = Header(None)):
    if not x_api_key or not hmac.compare_digest(x_api_key.encode(), API_KEY.encode()):
        raise HTTPException(401, 'Invalid API key')


def check_script(script):
    """Bound GPU cost before building; build_canvas checks the shape (starts, panels, size % 16)."""
    if not isinstance(script, dict):
        raise ValueError('script must be an object')
    segs = script.get('segments')
    if not isinstance(segs, list) or not 1 <= len(segs) <= MAX_SEGMENTS:
        raise ValueError(f'segments must be a list of 1..{MAX_SEGMENTS}')
    if any(not isinstance(s, dict) or not isinstance(s.get('prompt'), str) or not s['prompt'].strip() for s in segs):
        raise ValueError('every segment needs a non-empty prompt')
    boards = script.get('storyboard_prompts') or [script.get('storyboard_prompt')]
    if not 1 <= len(boards) <= MAX_BOARDS or any(not isinstance(b, str) or not b.strip() for b in boards):
        raise ValueError(f'storyboard_prompt(s): 1..{MAX_BOARDS} non-empty prompts')
    w, h = script.get('size', [576, 1024])
    if not all(isinstance(v, int) and 256 <= v <= MAX_SIDE for v in (w, h)):
        raise ValueError(f'size sides must be integers 256..{MAX_SIDE}')


def build_graph(script, object_info, job_id):
    canvas = build_canvas(copy.deepcopy(script))
    for node in canvas['nodes']:
        if node['type'] == 'SaveVideo':
            node['widgets_values'][0] = f'video/vace_{job_id}'
        elif node['type'] == 'SaveImage':
            node['widgets_values'][0] = f'video/vace_{job_id}_{node["id"]}'
    video = next(n for n in canvas['nodes'] if n['type'] == 'CreateVideo')
    return canvas_to_api(canvas, object_info), video['title']


@app.get('/health', dependencies=[Depends(auth)])
async def health():
    try:
        async with httpx.AsyncClient(timeout=10) as client:
            r = await client.get(f'{COMFY}/system_stats')
            r.raise_for_status()
        return {'status': 'ok', 'comfy_url': COMFY, 'fps': FPS, 'max_segments': MAX_SEGMENTS}
    except httpx.HTTPError as e:
        raise HTTPException(503, 'ComfyUI is unavailable') from e


async def read_image(file):
    if file.content_type not in IMAGE_TYPES:
        raise HTTPException(422, 'Upload PNG, JPEG or WebP images')
    data = await file.read(MAX_IMAGE + 1)
    if not 0 < len(data) <= MAX_IMAGE:
        raise HTTPException(422, 'Each image must be 1 byte to 20 MiB')
    return data, IMAGE_TYPES[file.content_type], file.content_type


@app.post('/api/v1/generate_video', dependencies=[Depends(auth)])
async def generate_video(
    reference_image: UploadFile = File(...),
    script_json: str = Form(..., max_length=120000),
    extra_images: Optional[List[UploadFile]] = File(None),
):
    extra_images = extra_images or []
    try:
        script = json.loads(script_json)
        check_script(script)
    except (ValueError, TypeError) as e:
        raise HTTPException(422, f'Invalid director script: {e}') from e
    if len(extra_images) > MAX_EXTRA:
        raise HTTPException(422, f'At most {MAX_EXTRA} extra images')
    product = await read_image(reference_image)
    extras = [await read_image(f) for f in extra_images]
    job_id = uuid.uuid4().hex
    try:
        async with httpx.AsyncClient(timeout=120) as client:
            async def upload(data, suffix, mime):
                r = await client.post(f'{COMFY}/upload/image', files={'image': (uuid.uuid4().hex + suffix, data, mime)},
                                      data={'overwrite': 'false'})
                r.raise_for_status()
                u = r.json()
                return '/'.join(x for x in (u.get('subfolder', ''), u['name']) if x)
            # only uploaded files may name ComfyUI inputs
            script['product_image'] = await upload(*product)
            script['extra_images'] = [await upload(*x) for x in extras]
            r = await client.get(f'{COMFY}/object_info')
            r.raise_for_status()
            try:
                graph, length = build_graph(script, r.json(), job_id)
            except (ValueError, KeyError, TypeError) as e:
                raise HTTPException(422, f'Script does not build a valid VACE flow: {str(e)[:250]}') from e
            r = await client.post(f'{COMFY}/prompt', json={'prompt': graph, 'client_id': job_id})
            if r.status_code >= 400:
                raise HTTPException(502, f'ComfyUI rejected workflow: {r.text[:2000]}')
            result = r.json()
        return dict(result, length=length, status_path=f"/api/v1/jobs/{result['prompt_id']}")
    except httpx.HTTPError as e:
        raise HTTPException(502, 'ComfyUI is unavailable during submission') from e


def media_items(outputs):
    for node, output in outputs.items():
        seen = set()
        for kind in ('images', 'videos', 'gifs'):
            for item in output.get(kind, []):
                if not isinstance(item, dict) or 'filename' not in item or item.get('type', 'output') != 'output':
                    continue
                params = dict(filename=item['filename'], subfolder=item.get('subfolder', ''), type='output')
                identity = (params['filename'], params['subfolder'])
                if identity in seen:
                    continue
                seen.add(identity)
                yield dict(params, node=node, download_path='/api/v1/media?' + urlencode(params))


@app.get('/api/v1/jobs/{prompt_id}', dependencies=[Depends(auth)])
async def job(prompt_id: uuid.UUID):
    pid = str(prompt_id)
    try:
        async with httpx.AsyncClient(timeout=20) as client:
            r = await client.get(f'{COMFY}/history/{pid}')
            r.raise_for_status()
            data = r.json().get(pid)
            if data is None:
                r = await client.get(f'{COMFY}/queue')
                r.raise_for_status()
                queue = r.json()
                for key, status in (('queue_running', 'running'), ('queue_pending', 'pending')):
                    if any(item[1] == pid for item in queue.get(key, [])):
                        return {'prompt_id': pid, 'status': status}
                return {'prompt_id': pid, 'status': 'unknown'}
    except httpx.HTTPError as e:
        raise HTTPException(502, 'ComfyUI is unavailable during status check') from e
    media = list(media_items(data.get('outputs', {})))
    status = data.get('status', {})
    success = status.get('completed', False) and status.get('status_str', 'success') == 'success'
    return {'prompt_id': pid, 'status': 'complete' if success else 'failed',
            'images': [x for x in media if Path(x['filename']).suffix.lower() not in VIDEO_SUFFIXES],
            'videos': [x for x in media if Path(x['filename']).suffix.lower() in VIDEO_SUFFIXES],
            'details': status}


@app.get('/api/v1/media', dependencies=[Depends(auth)])
async def media(filename: str, subfolder: str = '', type: str = 'output'):
    if (not filename or '/' in filename or '\\' in filename or '..' in filename
            or '\\' in subfolder or PurePosixPath(subfolder).is_absolute()
            or '..' in PurePosixPath(subfolder).parts or type != 'output'):
        raise HTTPException(400, 'Invalid media path')
    try:
        async with httpx.AsyncClient(timeout=120) as client:
            r = await client.get(f'{COMFY}/view', params=dict(filename=filename, subfolder=subfolder, type=type))
            r.raise_for_status()
        return Response(r.content, media_type=r.headers.get('content-type', 'application/octet-stream'))
    except httpx.HTTPStatusError as e:
        raise HTTPException(404 if e.response.status_code == 404 else 502, 'Media unavailable') from e
    except httpx.RequestError as e:
        raise HTTPException(502, 'ComfyUI is unavailable during download') from e
