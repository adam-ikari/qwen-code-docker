# 步骤 1: 使用官方的 Node.js 20 slim 版本作为基础镜像
# slim 版本包含了运行 npm 所需的最小依赖，可以减小最终镜像的体积
FROM node:20-slim

# 步骤 2: 全局安装 @qwen-code/qwen-code CLI 工具
# 使用 --no-update-notifier 来禁止 npm 的更新提示
# 使用 --no-fund 来禁止 npm 的资金募集提示
# 在同一层 (同一个 RUN) 中清理 npm 缓存，以进一步减小镜像体积
RUN npm install -g @qwen-code/qwen-code --no-update-notifier --no-fund && \
    npm cache clean --force

# 步骤 3: 设置容器的入口点 (Entrypoint)
# 这使得容器本身就像一个 `qwen` 可执行文件。
# 当你运行 `docker run my-qwen-image --some-arg` 时,
# `--some-arg` 会被直接传递给 `qwen` 命令。
ENTRYPOINT ["qwen"]

