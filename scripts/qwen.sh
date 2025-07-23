#!/bin/bash

# 当任何命令失败时，立即退出脚本
set -e

# --- 配置 ---
# 要运行的镜像名称和标签
IMAGE_NAME="qwen-code"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

# --- 检查镜像是否存在 ---
# 为了提供更友好的用户体验，先检查镜像是否存在
if ! docker image inspect "${FULL_IMAGE_NAME}" &> /dev/null; then
    echo "❌ Error: Docker image '${FULL_IMAGE_NAME}' not found locally."
    echo "   Hint: Please build the image first by running ./build.sh"
    exit 1
fi

# --- 执行 ---
echo "🚀 Running '${FULL_IMAGE_NAME}' with arguments: $@"
echo "   (Current directory '$(pwd)' is mounted to '/app' inside the container)"
echo "   (Host directory '${HOME}/.qwen' is mounted to '/home' inside the container)"

# 检查 ~/.qwen 目录是否存在，不存在则创建
if [ ! -d "${HOME}/.qwen" ]; then
    echo "⚠️ Directory '${HOME}/.qwen' not found, creating it..."
    mkdir -p "${HOME}/.qwen"
fi

# 运行 Docker 容器
# --rm:      容器退出后自动删除
# -it:       以交互模式运行，允许颜色输出和用户输入
# -v:        将当前目录挂载到容器的 /app 目录
# -v:        将宿主机的 ~/.qwen 目录挂载到容器的 /home 目录
# -w:        将容器内的工作目录设置为 /app
# "$@":      将所有传递给此脚本的参数 ($1, $2, ...) 传递给 qwen 命令
docker run --rm -it \
  -v "$(pwd)":/app \
  -v "${HOME}/.qwen":/app/.qwen \
  -w /app \
  "${FULL_IMAGE_NAME}" "$@"
