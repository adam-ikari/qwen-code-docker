# Qwen-Code Docker 运行环境

本项目为 [`@qwen-code/qwen-code`](https://www.npmjs.com/package/@qwen-code/qwen-code) 命令行工具提供了便捷的 Docker 化运行环境。您无需在本地安装 Node.js 或该软件包即可使用 `qwen` 命令。

项目包含构建、运行和测试 Docker 镜像的辅助脚本，以及自动构建并发布新版本到 Docker Hub 的 GitHub Actions 工作流。

## 功能特性

- **便携环境**：在任何安装了 Docker 的环境中运行 `qwen-code`
- **版本标签**：镜像自动标记 `qwen-code` 版本号
- **易用脚本**：
  - `build.sh`：构建本地 Docker 镜像
  - `run.sh`：像本地安装一样运行 `qwen` 命令
  - `test.sh`：验证本地镜像是否正常工作
- **自动构建**：GitHub Action 每天检查新版本并发布到 Docker Hub

## 前提条件

- **Docker**：必须安装并运行
- **Bash**：用于执行辅助脚本 (`.sh` 文件)
- **npm**：`build.sh` 脚本需要从 npm 仓库查询最新软件包版本

## 快速开始

### 推荐方式：从 GitHub 下载 qwen.sh

1. 下载运行脚本：

```bash
curl -O https://raw.githubusercontent.com/adam-ikari/qwen-code-docker/main/scripts/qwen.sh
chmod +x qwen.sh
```

2. 设置环境变量 (任选一种方式):

1) 临时设置(仅当前会话有效):
```bash
export OPENAI_API_KEY="your_api_key_here"
export OPENAI_BASE_URL="your_api_base_url_here"
export OPENAI_MODEL="your_api_model_here"
```

2) 永久设置(添加到shell配置文件 ~/.bashrc 或 ~/.zshrc):
```bash
echo 'export OPENAI_API_KEY="your_api_key_here"
export OPENAI_BASE_URL="your_api_base_url_here"
export OPENAI_MODEL="your_api_model_here"' >> ~/.bashrc
source ~/.bashrc
```

3. 运行脚本：
```bash
./qwen.sh [command]
```

### 可选方式：本地构建

适用于需要自定义构建的高级用户：

**1. 构建 Docker 镜像**

首先使脚本可执行：

```bash
chmod +x build.sh run.sh
```

然后运行构建脚本：

```bash
./build.sh
```

这将创建本地镜像标签：`qwen-code:<版本号>` 和 `qwen-code:latest`。

**2. 运行 `qwen` 命令**

使用辅助脚本运行命令：

```bash
OPENAI_API_KEY="your_api_key_here" \
OPENAI_BASE_URL="your_api_base_url_here" \
OPENAI_MODEL="your_api_model_here" \
./qwen.sh [command]
```

```bash
# 查看版本（验证安装）
./qwen.sh --version

# 查看帮助菜单
./qwen.sh --help

# 运行操作本地文件的命令
# (假设 'qwen analyze' 是有效命令)
touch my_file.js
./qwen.sh analyze my_file.js
```

## 脚本说明

#### `build.sh`

此脚本自动化构建过程：

1. 从 npm 仓库查询 `@qwen-code/qwen-code` 的最新版本
2. 使用 `Dockerfile` 构建 Docker 镜像
3. 用特定版本号标记镜像 (如 `qwen-code:1.2.3`)
4. 在项目根目录保存压缩的 `.tar.gz` 镜像存档

#### `qwen.sh`

这是使用工具的主要入口点，它封装了 `docker run` 命令：

- 运行 `qwen-code:latest` 镜像
- 将当前目录 (`pwd`) 挂载到容器内的 `/app` 目录
- 将主机的 `~/.qwen` 目录挂载到容器内的 `/home` 目录（用于持久化配置和数据存储）
- 设置 `/app` 为工作目录
- 将所有脚本参数直接传递给 `qwen` 命令
- 执行后自动清理容器 (`--rm`)

如果 `~/.qwen` 目录不存在，脚本会自动创建它。

## GitHub Actions 自动构建

`.github/workflows/daily-update.yml` 文件定义了自动更新 Docker Hub 镜像的 GitHub Actions 工作流。

- **触发条件**：每日定时运行 (`cron`) 或手动触发 (`workflow_dispatch`)
- **逻辑**：
  1. 从 npm 获取 `@qwen-code/qwen-code` 的最新版本号
  2. 检查 Docker Hub 是否已存在该版本标签的镜像
  3. 如果标签**不存在**，则构建新镜像
  4. 新镜像以两个标签推送到 Docker Hub：特定版本号和 `latest`

要在您自己的 fork 中使用此 action，您需要在 `Settings > Secrets and variables > Actions` 中配置以下仓库密钥：

- `DOCKERHUB_USERNAME`：您的 Docker Hub 用户名
- `DOCKERHUB_TOKEN`：Docker Hub 访问令牌

您还需要更新工作流文件中的 `DOCKER_IMAGE_NAME` 环境变量，指向您的 Docker Hub 仓库。

## 加载已保存的镜像

`build.sh` 脚本会创建一个 `qwen-code-x.y.z.tar.gz` 文件。您可以将此文件传输到另一台机器并加载到 Docker 中，无需重新构建：

```bash
docker load < qwen-code-x.y.z.tar.gz
```