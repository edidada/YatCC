#!/bin/bash
# Build LLVM 22.1.8 from the monorepo source archive.
# LLVM 22+ no longer publishes split llvm-*.src.tar.xz / clang-*.src.tar.xz /
# cmake-*.src.tar.xz assets; the release ships a single
# llvm-project-*.src.tar.xz containing llvm/, clang/, cmake/ and friends.
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

VER=22.1.8
TARBALL=llvm-project-${VER}.src.tar.xz
if [ ! -f "$TARBALL" ]; then
  wget -O "$TARBALL" https://github.com/llvm/llvm-project/releases/download/llvmorg-${VER}/${TARBALL}
fi

tar -xJf "$TARBALL"
mv llvm-project-${VER}.src source

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
