
## Task 4 示例程序编译成功

### 构建配置

✅ **CMakeLists.txt已更新**

在根目录的CMakeLists.txt中添加了task4_examples子目录的构建配置。

#### 修改内容

```cmake
# 任务
add_subdirectory(task)

# Task 4 示例程序
add_subdirectory(task4_examples)

# 评测
add_subdirectory(test)
```

### Task 4 示例程序CMakeLists.txt

✅ **创建了task4_examples/CMakeLists.txt**

为Task 4示例程序创建了独立的CMakeLists.txt，支持：
- C++17标准
- 自动构建所有示例程序
- 输出到examples子目录

#### 构建的程序

1. **01_constant_folding** - 常量折叠优化示例
2. **02_mem2reg** - 内存到寄存器提升优化示例
3. **03_static_call_counter** - 静态调用计数分析示例

### 编译结果

✅ **所有示例程序编译成功**

```bash
$ cmake -B build/task4_examples -S task4_examples
$ cmake --build build/task4_examples
[ 16%] Building CXX object CMakeFiles/01_constant_folding.dir/01_constant_folding.cpp.o
[ 33%] Linking CXX executable examples/01_constant_folding
[ 33%] Built target 01_constant_folding
[ 50%] Building CXX object CMakeFiles/02_mem2reg.dir/02_mem2reg.cpp.o
[ 66%] Linking CXX executable examples/02_mem2reg
[ 66%] Built target 02_mem2reg
[ 83%] Building CXX object CMakeFiles/03_static_call_counter.dir/03_static_call_counter.cpp.o
[100%] Linking CXX executable examples/03_static_call_counter
[100%] Built target 03_static_call_counter
```

#### 可执行文件

- **01_constant_folding**: 162,256 bytes
- **02_mem2reg**: 262,352 bytes
- **03_static_call_counter**: 232,168 bytes

### 运行测试

✅ **所有示例程序运行正常**

#### 1. 常量折叠优化 (01_constant_folding)

```bash
$ ./01_constant_folding --help
=== 常量折叠优化开始 ===
处理函数: example
  折叠: 3 + 5 = 8
  替换指令 add1 的所有使用为 8
  折叠: 10 - 2 = 8
  替换指令 sub1 的所有使用为 8
  折叠: 4 * 6 = 24
  替换指令 mul1 的所有使用为 24
  折叠: 20 / 4 = 5
  替换指令 div1 的所有使用为 5
  删除指令: add1
  删除指令: sub1
  删除指令: mul1
  删除指令: div1
=== 常量折叠优化完成，共折叠 4 个指令 ===
```

#### 2. 内存到寄存器提升 (02_mem2reg)

```bash
$ ./02_mem2reg --help
=== 内存到寄存器提升优化开始 ===
处理函数: example
  可提升的alloca: x
找到 1 个可提升的alloca指令
  为alloca x 插入PHI节点
  执行SSA重命名
    Store创建新版本: x_v1
    Store创建新版本: x_v2
    Store创建新版本: x_v3
    替换load load1 为版本 x_v3
  删除alloca和内存操作指令
    删除alloca: x
=== 内存到寄存器提升优化完成 ===
```

#### 3. 静态调用计数 (03_static_call_counter)

```bash
$ ./03_static_call_counter --help
=== 静态调用计数分析开始 ===
分析函数: main
  发现调用: helper1 (当前计数: 1)
  发现调用: helper1 (当前计数: 2)
  发现调用: helper1 (当前计数: 3)
  发现调用: helper2 (当前计数: 1)
  发现调用: helper2 (当前计数: 2)
  发现调用: helper3 (当前计数: 1)
  发现调用: helper3 (当前计数: 2)
  发现调用: helper3 (当前计数: 3)
  发现调用: helper3 (当前计数: 4)
  发现调用: helper3 (当前计数: 5)
分析函数: helper1
  发现调用: helper2 (当前计数: 3)
分析函数: helper2
  发现调用: helper3 (当前计数: 6)
分析函数: helper3
=== 静态调用计数分析完成 ===

=== 函数调用统计结果 ===
函数名  调用次数
----------------
helper3 6
helper2 3
helper1 3
----------------
总计: 3 个不同函数被调用
总调用次数: 12
平均调用次数: 4
```

### 总结

✅ **Task 4示例程序完全可用**

所有三个编译器优化示例程序都已经：
1. ✅ 成功编译
2. ✅ 可以正常运行
3. ✅ 输出正确结果
4. ✅ 通过CMake构建系统管理

这些示例程序展示了编译器优化的核心技术，不依赖LLVM库，使用纯C++实现，便于学习和理解。
