Kiểm tra API regression với fakeComfy/S3; lifecycle readinesstimeout/childexit/SIGTERM; auth/key/jobs persistence; secret khôngtrongcontext/history/log. Model tải vào partial, validatesize/SHA, resumeRange, không ghi target hoàn tất khi checksum sai; kiểm tra existingweights. Build/run API nonroot vớiupstream/S3fake; 10200 docs200,401wrongkey,health200whenComfyready/503otherwise. Compose requiredAWS bucket, GPUservicehealthcheck, restartunlessstopped, chỉAPIpublish, modelinitprofilemanual. ImageVast thiếuweights/GPU failclear không cài dependencies runtime. GPUbuild/check tách khỏi modeldownload; không inferenceGPU nếu không cócard. No commit.

## Kết quả kiểm chứng Docker local

- Build ba target api/comfyui/vast thành công; pip check GPU không có dependency hỏng; Dockerfile --check không warnings; Compose config --quiet PASS.
- API Python3.12: 18/18 unittest API/S3 PASS trong container --network none.
- Image Vast Python3.11/PyTorch: 18/18 API regression PASS.
- 11/11 test Docker Linux PASS: supervisor child exit/readiness/SIGTERM, model init SIGTERM, resume/ignored-range/checksum/atomic publish, không chuyển HF token sang host redirect khác.
- Docker smoke PASS: UID10001, docs200/auth401/health200; health fail khi fakeComfy tắt; key và job SQLite giữ sau restart; fakeAWS, không S3 thật. Tài nguyên test có tên random được dọn.
- ComfyUI CPU smoke PASS, đủ 17 workflow class_type. Launcher test đầu thiếu thư mục user nên fail; script comfy_cpu_smoke.ps1 đã tạo thư mục giống entrypoint thật và PASS. Không đổi production CLI để né lỗi test.
- Vast fail-fast khi thiếu models PASS. Không download 17.3GB weights, không chạy inferenceGPU, không gọi S3 thật, không push registry/thuê/sửa Vast, không commitGit.

GPU generation/ad-edit và S3 end-to-end vẫn là kiểm tra release cần thực hiện trên instance có model/GPU. Không coi CPU startup hay image build là xác nhận sinh ảnh.
