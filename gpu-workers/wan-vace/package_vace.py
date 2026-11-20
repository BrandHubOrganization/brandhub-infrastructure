"""Build every flow in flows/<genre>/ from its director script, then zip wan_vace_bundle.zip (allowlist; never models or keys).

  python package_vace.py

Script with "segments" -> Wan VACE flow (build_vace_flow.py); script with "voice_audio" -> S2V talking flow
(build_ugc_flow.py). Each flow is written next to its script as <SaveVideo name>_GUI.json.
"""
import json
import zipfile
from pathlib import Path

from build_ugc_flow import build as build_ugc
from build_vace_flow import build_canvas

ROOT = Path(__file__).resolve().parent
B, FLOWS = ROOT / 'wan_vace_bundle', ROOT / 'flows'

for old in FLOWS.glob('*/*_GUI.json'):
    old.unlink()
for src in sorted(FLOWS.glob('*/*.json')):
    script = json.loads(src.read_text(encoding='utf-8'))
    graph = build_canvas(script) if 'segments' in script else build_ugc(script) if 'voice_audio' in script else None
    if graph is None:
        continue
    save = next(n for n in graph['nodes'] if n['type'] == 'SaveVideo')
    out = src.with_name(save['widgets_values'][0].split('/')[-1] + '_GUI.json')
    out.write_text(json.dumps(graph, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f'{out.relative_to(ROOT)}: {len(graph["nodes"])} nodes')

files = [ROOT / 'build_vace_flow.py', ROOT / 'build_ugc_flow.py', B / 'setup.sh', B / 'README_VI.md',
         B / 'vace_api.py', B / 'canvas_api.py', B / 'start_api.py', B / 'requirements-api.txt',
         B / 'director/PROMPT_RULES_WAN.md', *sorted((B / 'resources').glob('*.json'))]
files += sorted(p for p in FLOWS.rglob('*') if p.is_file() and p.suffix in ('.json', '.md', '.png', '.webp', '.jpg', '.mp3', '.wav'))
out = ROOT / 'wan_vace_bundle.zip'
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
    for p in files:
        rel = p.relative_to(ROOT).as_posix()
        z.write(p, 'wan_vace_bundle/' + rel if rel.startswith('flows/') else rel)
print(f'{len(files)} files -> {out} ({out.stat().st_size:,} bytes)')
