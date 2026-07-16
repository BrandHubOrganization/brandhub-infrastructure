#!/bin/bash
# DA-E09-04: Script to clone all BrandHub repositories
# Usage: ./clone-all.sh

ORG="brandhub-capstone"
REPOS=(
    "brandhub-ai-service"
    "brandhub-business-service"
    "brandhub-api-gateway"
    "brandhub-frontend-web"
    "brandhub-frontend-mobile"
    "brandhub-infrastructure"
    "brandhub-docs"
)

echo "========================================="
echo "Cloning repositories from: $ORG"
echo "========================================="

for REPO in "${REPOS[@]}"; do
    if [ -d "$REPO" ]; then
        echo "✅ Directory $REPO already exists. Pulling latest changes..."
        cd "$REPO" || exit
        git pull
        cd ..
    else
        echo "🚀 Cloning $REPO..."
        git clone "https://github.com/$ORG/$REPO.git"
    fi
    echo "-----------------------------------------"
done

echo "🎉 All repositories have been processed successfully!"
