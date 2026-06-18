#!/bin/bash
set -e

# ============================================================
#  部署配置 — 修改这里匹配你的 ECS 和 GitHub 仓库
# ============================================================
ECS_HOST="${ECS_HOST:-47.99.244.154}"
ECS_USER="${ECS_USER:-root}"
ECS_PORT="${ECS_PORT:-22}"

# GitHub 仓库地址（填入你的 repo 地址）
GIT_REPO="${GIT_REPO:-https://github.com/susucain/agui-frontend.git}"
GIT_BRANCH="${GIT_BRANCH:-main}"

IMAGE_NAME="agui-frontend"
IMAGE_TAG="latest"
REMOTE_DIR="/opt/agui-frontend"
TAR_FILE="${IMAGE_NAME}.tar"

# ============================================================
echo "=========================================="
echo "  agui-frontend 部署脚本"
echo "  目标: ${ECS_USER}@${ECS_HOST}:${ECS_PORT}"
echo "=========================================="

# ---- Step 1: 本地构建 Docker 镜像 ----
echo ""
echo "[1/6] 本地构建 Docker 镜像..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
echo "  ✓ 构建完成"

# ---- Step 2: 导出镜像为 tar 文件 ----
echo ""
echo "[2/6] 导出镜像为 tar 文件..."
docker save ${IMAGE_NAME}:${IMAGE_TAG} > ${TAR_FILE}
echo "  ✓ 导出完成 ($(du -h ${TAR_FILE} | cut -f1))"

# ---- Step 3: 上传镜像到 ECS 临时目录 ----
echo ""
echo "[3/6] 上传镜像到 ECS..."
ssh -p ${ECS_PORT} ${ECS_USER}@${ECS_HOST} "mkdir -p /tmp/deploy ${REMOTE_DIR}"
scp -P ${ECS_PORT} ${TAR_FILE} ${ECS_USER}@${ECS_HOST}:/tmp/deploy/
echo "  ✓ 上传完成"

# ---- Step 4: ECS 上同步源码 + 部署 ----
echo ""
echo "[4/6] 同步源码并部署..."
ssh -p ${ECS_PORT} ${ECS_USER}@${ECS_HOST} << ENDSSH
set -e

# -- 4a. 同步 GitHub 源码 --
cd ${REMOTE_DIR}
if [ -d ".git" ]; then
    echo "  → 已有仓库，执行 git pull..."
    git fetch origin ${GIT_BRANCH}
    git reset --hard origin/${GIT_BRANCH}
else
    echo "  → 首次部署，执行 git clone..."
    git clone --branch ${GIT_BRANCH} --single-branch ${GIT_REPO} .
fi
echo "  ✓ 源码同步完成 (commit: \$(git rev-parse --short HEAD))"

# -- 4b. 加载镜像并启动容器 --
echo "  → 停止旧容器..."
docker compose -f docker-compose.ecs.yml down 2>/dev/null || true

echo "  → 加载新镜像..."
docker load < /tmp/deploy/${TAR_FILE}

echo "  → 启动容器..."
docker compose -f docker-compose.ecs.yml up -d

echo "  → 清理临时文件..."
rm -f /tmp/deploy/${TAR_FILE}

echo ""
echo "  ✓ 容器已启动"
docker compose -f docker-compose.ecs.yml ps
ENDSSH

# ---- Step 5: 本地清理 ----
echo ""
echo "[5/5] 清理本地临时文件..."
rm -f ${TAR_FILE}

echo ""
echo "=========================================="
echo "  ✓ 部署完成!"
echo "  访问地址: http://${ECS_HOST}"
echo "=========================================="
