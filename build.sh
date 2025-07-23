#!/bin/bash

# 当任何命令失败时，立即退出脚本
set -e

# --- 配置 ---
# 要查询的 npm 包名
PACKAGE_NAME="@qwen-code/qwen-code"
# Docker 镜像的名称
IMAGE_NAME="qwen-code"
# 产物路径
DIST_PATH="dist"

# --- 执行步骤 ---

echo "🔍 Step 1/3: Querying npm registry for the latest version of ${PACKAGE_NAME}..."
# 1. 使用 `npm view` 命令直接从 npm 仓库获取最新的版本号
#    `--json` 标志可以确保即使有其他输出，我们也能稳定地只获取版本字符串
IMAGE_TAG=$(npm view ${PACKAGE_NAME} version)
if [ -z "$IMAGE_TAG" ]; then
    echo "❌ Error: Could not retrieve package version. Please check your network connection and if the package '${PACKAGE_NAME}' exists."
    exit 1
fi
echo "✅ Version found: ${IMAGE_TAG}"

# 定义最终的镜像全名和输出文件名
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"
OUTPUT_FILENAME="${IMAGE_NAME}-${IMAGE_TAG}.tar.gz"

echo "🚀 Step 2/3: Building Docker image: ${FULL_IMAGE_NAME}..."
# 2. 使用获取到的版本号作为标签来构建镜像
docker build -t "${FULL_IMAGE_NAME}" .
echo "✅ Build complete."

echo "📦 Step 3/3: Saving Docker image to ${OUTPUT_FILENAME}..."
mkdir -p "${DIST_PATH}"
# 3. 将最终的镜像保存为 .tar 文件，并使用 gzip 进行压缩
docker save "${FULL_IMAGE_NAME}" | gzip > "${DIST_PATH}/${OUTPUT_FILENAME}"

echo "🎉 Success! Docker image saved to ${OUTPUT_FILENAME}"
echo "You can load this image on another machine using: docker load < ${OUTPUT_FILENAME}"
