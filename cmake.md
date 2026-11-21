# CMake / 构建工具链 —— 本项目用到的知识点

> ai.md 里有专门的「CMake 各 target 作用」章节，本文只讲**用到的 CMake 语法与构建工具概念**。
> 环境：CMake ≥ 3.20、Ninja、`lld`、CTest；`config.cmake` 是用户配置文件。

## 在本项目中的位置

| 位置 | 作用 |
|---|---|
| `CMakeLists.txt` | 顶层：`include(config.cmake)`、`project`、`find_package(Python3)`、`add_subdirectory` |
| `config.cmake` | 学号/姓名、`TASK1_WITH`/`TASK2_WITH`、`*_REVIVE`、三个 `YatCC_*_DIR` |
| `task/CMakeLists.txt` | `find_package` 各依赖、`add_task()` 宏、`configure_file`、INTERFACE 目标 |
| `task/config-*.cmake.in` | 生成到 `task/N/config.cmake` 的模板 |
| `test/task*/CMakeLists.txt` | `add_custom_target` + `add_test` 构成 answer/score |
| `.github/workflows/cmake-single-platform.yml` | CI 里的 configure / build / score 命令 |

## 需要掌握的知识点

1. **顶层配置注入** —— `include(config.cmake)` 在 `project()` 之前（`CMakeLists.txt:1-4`），后面所有 `add_subdirectory` 都能读到 `TASK1_WITH` 等变量。`CMAKE_C_STANDARD 17` / `CMAKE_CXX_STANDARD 17` 统一语言标准。

2. **`find_package` 两种模式** —— Module 模式（`FLEX`、`BISON`、`Python3`）与 Config 模式（`antlr4-runtime`、`antlr4-generator`、`pybind11`、`LLVM`）。后者靠 `xxx_DIR` 指向 `<prefix>/lib/cmake/<pkg>` 或 `share/cmake/<pkg>`，由 `config.cmake:36-51` 给出。找不到包时先查 `xxx_DIR` 再查 `CMAKE_PREFIX_PATH`。

3. **`configure_file(... @ONLY)`** —— `task/CMakeLists.txt:21-23` 把 `config-N.cmake.in` 里的 `@VAR@` 替换后写进**源码目录** `task/N/config.cmake`（被 `.gitignore` 的 `*/config.cmake` 忽略）。只在 STUDENT_ID/NAME 非空时生成。

4. **INTERFACE IMPORTED 目标** —— `add_library(LLVM INTERFACE IMPORTED)` + `target_include_directories/link_directories/link_libraries`，把系统 LLVM 包装成一个不编译、只传递编译/链接选项的目标（`task/CMakeLists.txt:11-17`）。同理 `pybind11::embed`。

5. **`add_custom_target` 的两种用法** —— 聚合：`add_custom_target(task4 DEPENDS task4-classic task4-llm)`（`task/4/CMakeLists.txt:22`）；命令：`add_custom_target(task0-answer COMMAND python3 ...)`、`taskN-score`、`taskN-pack`（`test/*/CMakeLists.txt`）。

6. **CTest** —— `include(CTest)`（`CMakeLists.txt:5`）+ `add_test(NAME task1/<case> COMMAND task1 <input> <output>)`（`test/task1/CMakeLists.txt:56`）。score.py 用 `ctest -R '^task1/...'` 按正则跑单个测例，`CTEST_TEST_TIMEOUT` 在 `config.cmake:54` 设为 3 秒。

7. **条件子目录** —— `task/1/CMakeLists.txt:3-13` 按 `TASK1_WITH` 选 `flex` 或 `antlr`；`task/2` 同理按 `TASK2_WITH` 选 `bison` 或 `antlr`。这是**配置期**决定，缓存后不会因改 config.cmake 自动切换。

8. **常用命令** —— `cmake -B <dir> -DCMAKE_BUILD_TYPE=Release`（`-G Ninja` 可选）、`cmake --build <dir> --target <t>`、`file(GLOB ...)` 收集源码、`target_compile_definitions` 注入 `TASK4_LLM` / `TASK4_DIR`（`task/4/CMakeLists.txt:19-20`）。

9. **FetchContent（间接）** —— ANTLR C++ runtime 内部用它拉 googletest；CMake 4.x 拒绝旧 `cmake_minimum_required`，故 `antlr/setup.sh` 加 `-DANTLR_BUILD_CPP_TESTS=OFF` 关掉。

## 容易踩的坑

- **切换 `TASK1_WITH`/`TASK2_WITH` 必须换 build 目录**：CMake 缓存里记着 `add_subdirectory(flex|antlr)` 的结果。CI 用 `build-flex` / `build-antlr` 两个目录分别 configure（`.github/workflows/cmake-single-platform.yml`）。
- **`config.cmake` 里的环境变量**：`${YatCC_ANTLR_DIR}` 是普通 CMake 变量，shell 里 `export` 不会自动变成 CMake 变量；项目已加 `if(NOT ...) set(... "$ENV{...}")` 回退，也可用 `-DYatCC_*_DIR=...` 覆盖（`config.cmake:31-57`）。
- **`YatCC_*_DIR` 指向依赖根目录、不是 install 子目录**：setup.sh 装到 `<dir>/install`，config.cmake 再拼 `/install/...`；CI 的 job env 曾多写一层 `/install` 导致路径全错。
- **`build/` 与 `build-*` 被 gitignore**，不会污染 `git status`；但 `configure_file` 写进源码树的 `task/N/config.cmake` 也被 `*/config.cmake` 忽略。
