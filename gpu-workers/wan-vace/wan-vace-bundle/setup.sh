#!/usr/bin/env bash
# Wan 2.2 Fun VACE product video: install ComfyUI (pinned), download Wan VACE + Qwen storyboard models,
# + Wan S2V (UGC talking flow), copy every flow in flows/<genre>/ + its images, start ComfyUI on 10101. Disk: ~92 GB.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PY="${PY:-/venv/main/bin/python}"
COMFY="${COMFY_ROOT:-/workspace/ComfyUI}"
COMMIT=6b904b5fafd062effc1acbc46b1d3196922f7055

for c in git aria2c ffmpeg; do command -v $c >/dev/null || { apt-get update && apt-get install -y git aria2 ffmpeg; break; }; done
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
df -h /workspace | tail -1

if [ ! -f "$COMFY/main.py" ]; then
  git init "$COMFY" && git -C "$COMFY" remote add origin https://github.com/Comfy-Org/ComfyUI.git
  git -C "$COMFY" fetch --depth 1 origin $COMMIT && git -C "$COMFY" checkout --detach FETCH_HEAD
fi
# keep the image's Torch build; only add ComfyUI's other requirements
"$PY" -m pip freeze | grep -iE '^(torch|torchvision|torchaudio)==' > /tmp/torch-constraints.txt || true
"$PY" -m pip install -r "$COMFY/requirements.txt" -r "$HERE/requirements-api.txt" -c /tmp/torch-constraints.txt

get() {  # dir name url sha256
  local f="$COMFY/models/$1/$2"; mkdir -p "$COMFY/models/$1"
  if [ -f "$f" ] && echo "$4  $f" | sha256sum -c --status; then echo "ok  $2"; return; fi
  aria2c -x 16 -s 16 -c --console-log-level=warn -d "$COMFY/models/$1" -o "$2" "$3"
  echo "$4  $f" | sha256sum -c
}
# Wan 2.2 Fun VACE 14B (high + low noise experts, fp8) + lightx2v 4-step LoRAs + umt5 text encoder + Wan VAE
get diffusion_models wan2.2_fun_vace_high_noise_14B_fp8_scaled.safetensors   https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/ee6f4a40737a995bf5818954cfce6d59443b0f04/split_files/diffusion_models/wan2.2_fun_vace_high_noise_14B_fp8_scaled.safetensors   23130f30207f6c8697a5bead113ddc9904cfbb5e8fa51a550df3cee4d21fb54c
get diffusion_models wan2.2_fun_vace_low_noise_14B_fp8_scaled.safetensors   https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/ee6f4a40737a995bf5818954cfce6d59443b0f04/split_files/diffusion_models/wan2.2_fun_vace_low_noise_14B_fp8_scaled.safetensors   ca55a5cc543e28576edbd2079f8c1de05f71cd9e85bf96fab635f55663dbcb69
get loras wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors   https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/ee6f4a40737a995bf5818954cfce6d59443b0f04/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors   698321cb86bd30c4af06c9b84e656a1048c8cb54e06d50694536fb5de37fde41
get loras wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors   https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/ee6f4a40737a995bf5818954cfce6d59443b0f04/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors   ec95216e614b3c132c11bfb387b11feedf62163150ccc9068bca8a189771e75a
get text_encoders umt5_xxl_fp8_e4m3fn_scaled.safetensors   https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/ee6f4a40737a995bf5818954cfce6d59443b0f04/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors   c3355d30191f1f066b26d93fba017ae9809dce6c627dda5f6a66eaa651204f68
get vae wan_2.1_vae.safetensors   https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/ee6f4a40737a995bf5818954cfce6d59443b0f04/split_files/vae/wan_2.1_vae.safetensors   2fc39d31359a4b0a64f55876d8ff7fa8d780956ae2cb13463b0223e15148976b

# Wan 2.2 S2V 14B + wav2vec2 audio encoder: UGC talking flow (flows/ugc) only; skip with NO_S2V=1
if [ "${NO_S2V:-0}" != 1 ]; then
get diffusion_models wan2.2_s2v_14B_fp8_scaled.safetensors   https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/ee6f4a40737a995bf5818954cfce6d59443b0f04/split_files/diffusion_models/wan2.2_s2v_14B_fp8_scaled.safetensors   140e75af5534ac3d91e710d9df756f7032addd64b341ba2c1c70e3e6da9aa216
get audio_encoders wav2vec2_large_english_fp16.safetensors   https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/ee6f4a40737a995bf5818954cfce6d59443b0f04/split_files/audio_encoders/wav2vec2_large_english_fp16.safetensors   f0017a43ea57ef6b3d4866be607844bbd8cada6d30966f7d70044ed0d63d3f9e
fi

# Qwen Image 2.1 edit models (storyboards, UGC presenter photo)
get diffusion_models qwen_image_2.1_turbo_int8_convrot.safetensors \
  https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/aacf31a6d48e707f352ecba714cee0680da3479b/diffusion_models/qwen_image_2.1_turbo_int8_convrot.safetensors \
  8144a0182964aa8403ad6dbc011db837304167d235161b9aabaa8532e967314c
get text_encoders qwen3vl_8b_int8_convrot.safetensors \
  https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/aacf31a6d48e707f352ecba714cee0680da3479b/text_encoders/qwen3vl_8b_int8_convrot.safetensors \
  8bfd0f6e12abf2d2d697ecc888e5e90b0d6741d6708f05799f53afa560452e8f
get vae qwen_image_2.1_vae_bf16.safetensors \
  https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/aacf31a6d48e707f352ecba714cee0680da3479b/vae/qwen_image_2.1_vae_bf16.safetensors \
  bb21f7473051e1ac368515dd3f2e15cd44d7a11748ee8823e1ddca3e4876b7c9
get text_encoders qwen3.5_9b_qwen_image_2.1_pe_i2i.int8_convrot.safetensors \
  https://huggingface.co/Comfy-Org/Qwen-Image-2.1/resolve/aacf31a6d48e707f352ecba714cee0680da3479b/text_encoders/qwen3.5_9b_qwen_image_2.1_pe_i2i.int8_convrot.safetensors \
  32707d01b427e488af252b95c551989aad59f9fec611a694f5db6bde7f0f1f6c

mkdir -p "$COMFY/user/default/workflows" "$COMFY/input" /workspace/logs
for d in "$HERE"/flows/*/; do   # one workflow folder per genre (unbox, hero, tvc, ...)
  mkdir -p "$COMFY/user/default/workflows/$(basename "$d")"
  cp "$d"*_GUI.json "$COMFY/user/default/workflows/$(basename "$d")/"
  for f in "$d"*.png "$d"*.webp "$d"*.jpg "$d"*.mp3 "$d"*.wav; do [ -f "$f" ] && cp "$f" "$COMFY/input/"; done
done

if ! curl -sf http://127.0.0.1:10101/system_stats >/dev/null; then
  nohup "$PY" "$COMFY/main.py" --listen 0.0.0.0 --port 10101 --enable-cors-header "*" --cache-none > /workspace/logs/comfy_wan.log 2>&1 &
fi
for i in $(seq 120); do curl -sf http://127.0.0.1:10101/system_stats >/dev/null && break; sleep 2; done
curl -sf http://127.0.0.1:10101/system_stats >/dev/null || {
  echo "ComfyUI did not start, see /workspace/logs/comfy_wan.log"; tail -30 /workspace/logs/comfy_wan.log; exit 1; }
echo "READY: ComfyUI http://127.0.0.1:10101 (local only; do not expose: it has no password)"

# Worker API for the web/AI service (X-API-Key, port API_PORT=10200); key in wan-vace-bundle/.api_key unless API_KEY is set
(cd "$HERE" && "$PY" start_api.py)
API_PORT="${API_PORT:-10200}"

# Optional public link to the API via ngrok: NGROK_AUTHTOKEN=<token> bash setup.sh. The token is read from the
# environment only (never written into this bundle); ngrok keeps it in ~/.config/ngrok/ngrok.yml on this machine.
if [ -n "${NGROK_AUTHTOKEN:-}" ]; then
  if ! command -v ngrok >/dev/null; then
    curl -sSfL https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz | tar xz -C /usr/local/bin ngrok
  fi
  ngrok config add-authtoken "$NGROK_AUTHTOKEN" >/dev/null
  if ! curl -sf http://127.0.0.1:4040/api/tunnels >/dev/null; then
    nohup ngrok http "$API_PORT" --log stdout > /workspace/logs/ngrok.log 2>&1 &
  fi
  for i in $(seq 30); do
    URL=$(curl -sf http://127.0.0.1:4040/api/tunnels | "$PY" -c 'import json,sys; t=json.load(sys.stdin)["tunnels"]; print(t[0]["public_url"] if t else "")' 2>/dev/null || true)
    [ -n "$URL" ] && { echo "PUBLIC API: $URL  (AI service: LTX_WORKER_URL=$URL, key: cat $HERE/.api_key)"; break; }
    sleep 2
  done
  [ -n "${URL:-}" ] || { echo "ngrok did not start, see /workspace/logs/ngrok.log"; tail -20 /workspace/logs/ngrok.log; }
fi
