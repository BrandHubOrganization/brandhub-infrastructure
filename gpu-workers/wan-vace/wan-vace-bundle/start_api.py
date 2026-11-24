"""Check every VACE flow compiles against the running ComfyUI, then start the authenticated API (no GPU job)."""
import json
import os
import socket
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def get_json(url, key=None):
    request = urllib.request.Request(url, headers={'X-API-Key': key} if key else {})
    with urllib.request.urlopen(request, timeout=15) as response:
        return json.load(response)


def main():
    from vace_api import API_KEY, COMFY, build_graph

    port = int(os.getenv('API_PORT', '10200'))
    if not 1024 <= port <= 65535:
        raise ValueError('API_PORT must be between 1024 and 65535')
    health = f'http://127.0.0.1:{port}/health'
    with socket.socket() as probe:
        occupied = probe.connect_ex(('127.0.0.1', port)) == 0
    if occupied:
        try:
            if get_json(f'http://127.0.0.1:{port}/openapi.json')['info']['title'].startswith('Wan VACE') \
                    and get_json(health, API_KEY).get('status') == 'ok':
                print(f'READY: API http://127.0.0.1:{port} | Swagger /docs')
                return
        except (OSError, ValueError, KeyError):
            pass
        raise RuntimeError(f'Port {port} is occupied. No process was stopped; set another API_PORT.')
    object_info = get_json(COMFY + '/object_info')
    flows_dir = ROOT / 'flows' if (ROOT / 'flows').is_dir() else ROOT.parent / 'flows'
    for src in sorted(flows_dir.glob('*/*.json')):
        if src.name.endswith('_GUI.json'):
            continue
        script = json.loads(src.read_text(encoding='utf-8'))
        if 'segments' in script:
            graph, _ = build_graph(script, object_info, 'schema_check')
            print(f'Validated {src.parent.name}/{src.name}: {len(graph)} nodes; no GPU job submitted.', flush=True)
    (ROOT / 'logs').mkdir(exist_ok=True)
    with (ROOT / 'logs/api.log').open('ab') as output:
        process = subprocess.Popen([sys.executable, '-m', 'uvicorn', 'vace_api:app', '--host', '0.0.0.0', '--port', str(port)],
            cwd=ROOT, stdin=subprocess.DEVNULL, stdout=output, stderr=subprocess.STDOUT, start_new_session=True)
    for _ in range(30):
        if process.poll() is not None:
            raise RuntimeError('API startup failed; see wan-vace-bundle/logs/api.log')
        try:
            if get_json(health, API_KEY).get('status') == 'ok':
                print(f'READY: API http://127.0.0.1:{port} | Swagger /docs')
                print('API key: wan-vace-bundle/.api_key (value not printed). Public tunnel must target this port.')
                return
        except (OSError, ValueError):
            pass
        time.sleep(1)
    raise RuntimeError('API did not become ready; see wan-vace-bundle/logs/api.log')


if __name__ == '__main__':
    main()
