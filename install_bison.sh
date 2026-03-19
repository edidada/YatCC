#!/bin/bash

# Bison 3.0+ 安装脚本
# 适用于 Intel macOS 12.7

set -e  # 遇到错误立即退出

# 配置变量
BISON_VERSION="3.8.2"  # 可以根据需要修改版本号
BISON_DIR="bison-${BISON_VERSION}"
BISON_TAR="${BISON_DIR}.tar.xz"
BISON_URL="https://ftp.gnu.org/gnu/bison/${BISON_TAR}"
INSTALL_PREFIX="/usr/local"

# 备用下载镜像
MIRROR_URLS=(
    "https://mirrors.ustc.edu.cn/gnu/bison/${BISON_TAR}"
    "https://mirrors.tuna.tsinghua.edu.cn/gnu/bison/${BISON_TAR}"
    "https://mirrors.cloud.tencent.com/gnu/bison/${BISON_TAR}"
)

echo "=========================================="
echo "Bison ${BISON_VERSION} 安装脚本"
echo "=========================================="
echo "系统信息:"
echo "  macOS版本: $(sw_vers -productVersion)"
echo "  架构: $(uname -m)"
echo "  安装前缀: ${INSTALL_PREFIX}"
echo ""

# 检查是否已安装
if command -v bison &> /dev/null; then
    INSTALLED_VERSION=$(bison --version | head -1 | awk '{print $4}')
    echo "检测到已安装的Bison版本: ${INSTALLED_VERSION}"
    echo ""
    read -p "是否继续安装Bison ${BISON_VERSION}？(y/N): " confirm
    if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
        echo "取消安装"
        exit 0
    fi
fi

# 检查必要的工具
echo "检查必要的工具..."
for tool in xz tar gcc make; do
    if ! command -v ${tool} &> /dev/null; then
        echo "错误: 未找到 ${tool}"
        echo "请先安装必要的工具："
        echo "  xz: brew install xz"
        echo "  tar: 系统自带"
        echo "  gcc: xcode-select --install"
        echo "  make: 系统自带"
        exit 1
    fi
done
echo "所有必要工具已就绪"
echo ""

# 创建临时目录
TEMP_DIR=$(mktemp -d)
cd "${TEMP_DIR}"
echo "工作目录: ${TEMP_DIR}"
echo ""

# 下载Bison源代码
echo "开始下载Bison ${BISON_VERSION}..."
echo "主下载地址: ${BISON_URL}"
echo ""

# 尝试主下载地址
if curl -L -o "${BISON_TAR}" "${BISON_URL}" --max-time 60 --connect-timeout 30; then
    echo "✓ 下载成功: ${BISON_TAR}"
else
    echo "✗ 主下载地址失败，尝试备用镜像..."
    echo ""
    
    # 尝试备用镜像
    DOWNLOADED=false
    for mirror_url in "${MIRROR_URLS[@]}"; do
        echo "尝试镜像: ${mirror_url}"
        if curl -L -o "${BISON_TAR}" "${mirror_url}" --max-time 60 --connect-timeout 30; then
            echo "✓ 下载成功: ${BISON_TAR}"
            DOWNLOADED=true
            break
        else
            echo "✗ 镜像下载失败"
        fi
    done
    
    if [ "${DOWNLOADED}" = false ]; then
        echo ""
        echo "=========================================="
        echo "所有自动下载都失败了"
        echo "=========================================="
        echo ""
        echo "请手动下载Bison源代码："
        echo ""
        echo "方法1 - 使用curl（推荐）："
        echo "  cd ${TEMP_DIR}"
        echo "  curl -L -o ${BISON_TAR} ${BISON_URL}"
        echo ""
        echo "方法2 - 使用wget："
        echo "  cd ${TEMP_DIR}"
        echo "  wget -O ${BISON_TAR} ${BISON_URL}"
        echo ""
        echo "方法3 - 使用国内镜像："
        for i in "${!MIRROR_URLS[@]}"; do
            echo "  curl -L -o ${BISON_TAR} ${MIRROR_URLS[$i]}"
        done
        echo ""
        echo "下载完成后，重新运行此脚本"
        echo ""
        
        # 检查是否已手动下载
        if [ -f "${BISON_TAR}" ]; then
            echo "检测到已下载的文件: ${BISON_TAR}"
            read -p "是否使用此文件继续安装？(y/N): " confirm
            if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
                echo "取消安装"
                rm -rf "${TEMP_DIR}"
                exit 0
            fi
        else
            echo "未找到下载的文件，退出"
            rm -rf "${TEMP_DIR}"
            exit 1
        fi
    fi
fi

# 验证下载的文件
echo ""
echo "验证下载的文件..."
if [ ! -f "${BISON_TAR}" ]; then
    echo "错误: 未找到下载的文件"
    rm -rf "${TEMP_DIR}"
    exit 1
fi

FILE_SIZE=$(du -h "${BISON_TAR}" | cut -f1)
echo "文件大小: ${FILE_SIZE}"

# 解压
echo ""
echo "解压文件..."
tar -xf "${BISON_TAR}"
if [ ! -d "${BISON_DIR}" ]; then
    echo "错误: 解压失败"
    rm -rf "${TEMP_DIR}"
    exit 1
fi
echo "✓ 解压成功"
cd "${BISON_DIR}"

# 配置
echo ""
echo "配置编译选项..."
echo "  --prefix=${INSTALL_PREFIX}"
echo ""

./configure --prefix="${INSTALL_PREFIX}" \
    --disable-dependency-tracking \
    --disable-nls \
    --disable-rpath \
    --enable-threads=posix

if [ $? -ne 0 ]; then
    echo "错误: 配置失败"
    rm -rf "${TEMP_DIR}"
    exit 1
fi
echo "✓ 配置成功"

# 编译
echo ""
echo "开始编译..."
echo "使用 $(nproc) 个CPU核心进行编译"
echo ""

make -j$(nproc)

if [ $? -ne 0 ]; then
    echo "错误: 编译失败"
    rm -rf "${TEMP_DIR}"
    exit 1
fi
echo "✓ 编译成功"

# 安装
echo ""
echo "开始安装..."
echo "需要管理员权限，请输入密码..."
echo ""

sudo make install

if [ $? -ne 0 ]; then
    echo "错误: 安装失败"
    rm -rf "${TEMP_DIR}"
    exit 1
fi
echo "✓ 安装成功"

# 清理临时文件
echo ""
echo "清理临时文件..."
cd /
rm -rf "${TEMP_DIR}"
echo "✓ 清理完成"

# 更新动态库缓存
echo ""
echo "更新动态库缓存..."
if command -v brew &> /dev/null; then
    brew list
else
    sudo /usr/bin/update_dyld_shared_cache
fi

# 验证安装
echo ""
echo "=========================================="
echo "验证安装"
echo "=========================================="
echo ""

if command -v bison &> /dev/null; then
    NEW_VERSION=$(bison --version | head -1)
    echo "✓ Bison安装成功！"
    echo ""
    echo "版本信息:"
    echo "  ${NEW_VERSION}"
    echo ""
    echo "安装位置:"
    which bison
    echo ""
    echo "库文件位置:"
    ls -la "${INSTALL_PREFIX}/lib/" | grep liby.a || ls -la "${INSTALL_PREFIX}/lib/" | grep liby.dylib || echo "  未找到库文件"
    echo ""
    
    # 检查版本是否正确
    if [[ "${NEW_VERSION}" == *"${BISON_VERSION}"* ]]; then
        echo "✓ 版本验证成功"
    else
        echo "⚠ 警告: 安装的版本可能不正确"
        echo "  期望版本: ${BISON_VERSION}"
        echo "  实际版本: ${NEW_VERSION}"
    fi
else
    echo "✗ Bison未正确安装"
    echo "请检查安装路径: ${INSTALL_PREFIX}/bin"
    exit 1
fi

echo ""
echo "=========================================="
echo "安装完成！"
echo "=========================================="
echo ""
echo "下一步："
echo "1. 重新打开终端以使PATH生效"
echo "2. 运行 'bison --version' 验证安装"
echo "3. 重新编译YatCC的task2"
echo ""
