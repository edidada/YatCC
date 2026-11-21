# Python —— 本项目用到的知识点

> 版本/安装见 `ai.md`「三方库」：Python 3.12.3，`find_package(Python3 COMPONENTS Interpreter Development REQUIRED)` 在 `CMakeLists.txt:14`。
> 三个用途：① 评测脚本 ② 生成 C++ 头文件 ③ LLM 分支的 Python 侧实现（见 `pybind11.md`）。

## 在本项目中的位置

| 位置 | 作用 |
|---|---|
| `test/common.py` | 评测框架：`CasesHelper` / `ScoreReport` / 缓存工具 |
| `test/task*/answer.py` | 生成标准答案（调 clang、ctest） |
| `test/task*/score.py` | 逐测例比对输出/返回值、算分 |
| `task/2/antlr/SYsULexer.py` | 把 `.tokens` 转成 C++ 头 `SYsULexer.tokens.hpp` |
| `task/4/llm/__init__.py`、`task/5/llm/__init__.py` | LLM 客户端与响应清洗（`openai` SDK） |
| `test/diy-cases/*.py` | 自造测例的辅助脚本（如 `calculate_offsets.py`） |

## 需要掌握的知识点

1. **`find_package(Python3 COMPONENTS Interpreter Development)`** —— CMake 侧需要 `Python3_EXECUTABLE`（跑脚本）与 Python 头文件（pybind11 embed 链接 libpython）。`Development` 组件缺失会导致 pybind11 的 `check` 或 embed 链接失败。

2. **评测框架两个核心类**（`test/common.py`）：
   - `CasesHelper`（`:11`）：从 cases 表加载测例名/权重，提供 `open_case_report`、`open_case_input`、`of_case_bindir`、`of_bindir` 等路径方法，`load_file` 是入口。
   - `ScoreReport`（`:146`）：收集 `TestEntry`、算加权总分 `final_score()`、`dump_human_text` / `dump_autograder` 分别写 txt 与 json。
   - 辅助：`print_parsed_args`（`:268`）、`exit_if_cases_cached` / `cache_cases`（`:284-305`）用测例内容哈希做缓存，跳过重复评测。

3. **score.py 的固定套路** —— `argparse` 解析 `srcdir / bindir / cases_file / ctest_exe / comp_path / qemu_path / rtlib_path`；`CasesHelper.load_file` → `subps.run([ctest, "--test-dir", bindir, "-R", "^taskN/.*"])` 跑测例 → `score_one` 逐个比对 `answer.out` vs `output.out` 和 `Return Code` → `generate_score_report` 落盘。超时用 `subps.run(..., timeout=TIME_OUT)`（`test/task5/score.py:12`、`:102`、`:120`）。

4. **`subprocess` + 正则** —— 标准答案与程序输出都靠 `subps.run` 捕获到文件；返回值用 `re.findall(r"Return Code: ([-+]?\d*)", ...)` 解析（`test/task5/score.py:20-28`）。`--single` 支持只跑一个测例（`:266-313`）。

5. **`ctest -R` 与 `--test-dir`** —— CMake 的 `add_test(NAME task1/<case> ...)` 注册测例，score.py 用正则筛出单个/整组；`-R "^task5/.*"` 这类写法与 CMakeLists 里的 NAME 必须一致（`test/task1/CMakeLists.txt:56`）。

6. **`SYsULexer.py` 的代码生成** —— 读 `.tokens`（`name=value`，跳过 `#` 注释）生成 C++ 常量/命名空间头；由 `task/2/antlr/CMakeLists.txt` 的 `add_custom_command` 调用，输出进 `target` 的 include 路径。

7. **LLM 侧 Python**（`task/4/llm/__init__.py`）—— `openai.OpenAI` 客户端、会话管理 `create_new_session`/`delete_session`/`add_content`/`chat`；响应清洗函数 `remove_deepseek_r1_think`、`remove_md_block_marker(marker)`（闭包工厂）、`extract_text_from_xml(tag)` 用 `xml.etree.ElementTree` 解析。C++ 通过 `Py::list` 把这些函数当 handler 传进去（见 `pybind11.md`）。

8. **依赖包** —— `python3-pytest`（CI 装，给 pybind11 的 `check` target 用）、`openai`（LLM 分支运行时）；评测脚本本身只用标准库。

## 容易踩的坑

- **评测输入是预处理后的源文件**，不是 `test/cases/*.sysu.c`：`task0-answer` 用 `clang -E` 生成带 `#line` 的文件，Loc 里的绝对路径才对得上答案（见 `ai.md`「CMake 各 target 作用」）。
- **`score.py` 缺标准答案会直接 0 分**，且部分脚本在无工具链（ARM GCC/QEMU）时会降级：生成占位输出并判满分（`test/task5/score.py:64-74`），看日志时别误判为通过。
- **缓存机制**：`exit_if_cases_cached` 命中会跳过重跑，改了测例却没变结果时先查 `bindir` 里的缓存文件。
- **超时是硬失败**：`TIME_OUT=20`（task5），死循环测例会判"运行输出结果超时"。
