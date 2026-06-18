#!/bin/bash
set -e

# ============================================================
#  部署配置
# ============================================================
GIT_REPO="${GIT_REPO:-https://github.com/susucain/agui-frontend.git}"
GIT_BRANCH="${GIT_BRANCH:-main}"
PROJECT_DIR="/opt/agui-frontend"
NGINX_HTML="/usr/share/nginx/html"
NGINX_CONF="/etc/nginx/conf.d/default.conf"

echo "=========================================="
echo "  agui-frontend 部署脚本"
echo "=========================================="

# ---- Step 1: 同步源码 ----
echo ""
echo "[1/4] 同步 GitHub 源码..."
cd ${PROJECT_DIR}
if [ -d ".git" ]; then
    git fetch origin ${GIT_BRANCH}
    git reset --hard origin/${GIT_BRANCH}
else
    git clone --branch ${GIT_BRANCH} --single-branch ${GIT_REPO} .
fi
echo "  ✓ 同步完成 (commit: $(git rev-parse --short HEAD))"

# ---- Step 2: 部署静态资源 ----
echo ""
echo "[2/4] 部署静态资源到 nginx..."
rm -rf ${NGINX_HTML}/*
cp -r dist/* ${NGINX_HTML}/
echo "  ✓ 静态资源已复制"

# ---- Step 3: 部署 nginx 配置 ----
echo ""
echo "[3/4] 部署 nginx 配置..."
cp nginx.conf ${NGINX_CONF}
echo "  ✓ nginx 配置已更新"

# ---- Step 4: 重载 nginx ----
echo ""
echo "[4/4] 重载 nginx..."
nginx -t && sudo systemctl reload nginx
echo "  ✓ nginx 已重载"

echo ""
echo "=========================================="
echo "  ✓ 部署完成!"
echo "=========================================="
