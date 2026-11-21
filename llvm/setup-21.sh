#!/bin/bash
# Build LLVM 21.1.8 from the split source tarballs.
# LLVM 21 still publishes llvm-*.src.tar.xz, clang-*.src.tar.xz and
# cmake-*.src.tar.xz separately (LLVM 22+ switched to a single monorepo archive).
set -e # Exit on error

if [ -z "$YatCC_LLVM_DIR" ]; then
  cd $(dirname "$0")
else
  mkdir -p "$YatCC_LLVM_DIR"
  cd "$YatCC_LLVM_DIR"
fi

if [ -d install ]; then
  echo "ALREADY SETUP! - please remove the install directory to reinstall:"
  echo "  rm -rf $(realpath install)"
  exit 0
fi
rm -rf source build install

arch=$(uname -m)
if [ "$arch" = "x86_64" ]; then
  targets="X86"
elif [ "$arch" = "aarch64" ]; then
  targets="AArch64"
else
  echo "unsupported architecture: $arch"
  exit 1
fi

VER=21.1.8
BASE=https://github.com/llvm/llvm-project/releases/download/llvmorg-${VER}

for name in llvm clang cmake; do
  if [ ! -f ${name}-${VER}.src.tar.xz ]; then
    wget -O ${name}-${VER}.src.tar.xz ${BASE}/${name}-${VER}.src.tar.xz
  fi
done

mkdir source
for name in llvm clang cmake; do
  tar -xJf ${name}-${VER}.src.tar.xz -C source
  mv source/${name}-${VER}.src source/${name}
done

mkdir build install
cmake source/llvm -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_INSTALL_PREFIX=$(realpath install) \
  -DLLVM_ENABLE_PROJECTS="clang" \
  -DLLVM_TARGETS_TO_BUILD="$targets" \
  -DLLVM_BUILD_LLVM_DYLIB=ON \
  -DLLVM_LINK_LLVM_DYLIB=ON \
  -DLLVM_USE_LINKER=lld \
  -DLLVM_INCLUDE_BENCHMARKS=OFF \
  -DLLVM_INCLUDE_EXAMPLES=OFF \
  -DLLVM_INCLUDE_TESTS=OFF
cmake --build build --target install
