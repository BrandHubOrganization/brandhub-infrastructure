#!/bin/bash

# ==============================================================================
# DA-142: Script tự động clone hoặc pull 7 repositories của BrandHub
# ==============================================================================

ORG_NAME="BrandHubOrganization"
BASE_URL="https://github.com/${ORG_NAME}"

REPOS=(
    "brandhub-ai-service"
    "brandhub-api-gateway"
    "brandhub-business-service"
    "brandhub-infrastructure"
    "brandhub-mobile-app"
    "brandhub-publisher-service"
    "brandhub-web"
)

echo "Bắt đầu quá trình đồng bộ (Clone/Pull) cho tổ chức $ORG_NAME..."
echo "------------------------------------------------------------"

for REPO in "${REPOS[@]}"; do
    if [ -d "$REPO" ]; then
        echo "[PULL] Thư mục $REPO đã tồn tại. Đang cập nhật code mới nhất..."
        (cd "$REPO" && git pull)
    else
        echo "[CLONE] Thư mục $REPO chưa tồn tại. Đang tiến hành clone..."
        git clone "${BASE_URL}/${REPO}.git"
    fi
    echo "------------------------------------------------------------"
done

echo "🎉 Hoàn tất! Tất cả repositories đã được đồng bộ thành công!"
