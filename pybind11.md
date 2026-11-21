# pybind11 —— 本项目用到的知识点

> 版本/安装见 `ai.md`「三方库」：2.13.6，由 `pybind11/setup.sh` 装到 `pybind11/install`。
> 本项目用的是**嵌入模式（embed）**：在 C++ 进程里启动 Python 解释器，而不是把 C++ 暴露给 Python。

## 在本项目中的位置

| 位置 | 作用 |
|---|---|
| `task/4/llm/LLMHelper.cpp` | 封装 Python 侧的 `llm.LLMHelperImpl`（会话/对话） |
| `task/4/llm/PassSequencePredict.cpp` | 让 LLM 读 IR 与 Pass 摘要，预测 Pass 序列 |
| `task/4/llm/__init__.py` | Python 侧实现（OpenAI SDK + 响应清洗） |
| `task/5/llm/IRTrans.cpp` | LLM 直接把 IR 翻译成 ARM 汇编 |
| `task/4/CMakeLists.txt:10-20` | `task4-llm` target + `pybind11::embed` + `TASK4_LLM` / `TASK4_DIR` |
| `task/5/CMakeLists.txt:33-46` | 同理 `task5-llm` + `TASK5_LLM` / `TASK5_DIR` |
| `config.cmake:49-51` | `pybind11_DIR` 指向 `install/share/cmake/pybind11` |

## 需要掌握的知识点

1. **嵌入模式三件套** —— `#include <pybind11/embed.h>`、链接 `pybind11::embed`、`py::scoped_interpreter guard{}`。后者在作用域内启动/关闭解释器，**任何 Python API 调用都必须在它之后**（`task/4/main.cpp:62`、`task/5/main.cpp:50`）。一个进程只能有一个解释器实例。

2. **让解释器找到自定义模块** —— `Py::module_::import("sys").attr("path").attr("append")(TASK4_DIR)`，之后才能 `Py::module_::import("llm")`（`task/4/main.cpp:64-65`）。`TASK4_DIR` 由 `target_compile_definitions` 注入源码绝对路径。

3. **`py::object` 持有 Python 对象** —— `LLMHelper.hpp:32` 用 `pybind11::object mImpl` 保存 `llm.LLMHelperImpl(...)` 实例；`.attr("create_new_session")()` 调方法、`.cast<std::string>()` 转回 C++（`task/4/llm/LLMHelper.cpp:8-21`）。

4. **容器类型** —— `Py::str` / `Py::list` / `Py::dict` / `Py::module_`。`handlers.append(llm.attr("remove_md_block_marker")("xml"))` 把 Python 函数对象收集进 list（`task/4/llm/PassSequencePredict.cpp:81-83`）。

5. **关键字参数与字面量** —— `using namespace Py::literals` 后可用 `"name"_a = value`；`Py::dict("max_tokens"_a=8192, "stream"_a=false)` 对应 Python 关键字参数，`chat(..., **params)` 用 `**` 展开（`task/4/llm/LLMHelper.cpp:47-52`）。`Py::str(...).attr("format")("ir"_a=..., "passes"_a=...)` 对应 `str.format`（`PassSequencePredict.cpp:69-70`、`:125-126`）。

6. **提示词模板外置** —— `llm/prompts/*.xml` 是 XML 模板，C++ 读文件后交给 Python `format` 填充；`__init__.py` 里的 handler 负责 `remove_deepseek_r1_think`、`remove_md_block_marker`、`extract_text_from_xml` 等响应清洗。

7. **条件编译双 target** —— `TASK4_LLM` / `TASK5_LLM` 宏区分 classic 与 llm 可执行文件；`find_package(pybind11 2.13.6)` + `target_link_libraries(... pybind11::embed)`（`task/4/CMakeLists.txt:12-17`）。

## 容易踩的坑

- **没有有效 API 配置就别启用 LLM 分支**：`task/4/main.cpp:53-58` 检查 `apiKey[0] != '<'`，未配置时自动回退到经典 O3 优化流程，避免依赖外部服务导致 CI 挂掉；`task/5/main.cpp:58` 里 `<api-key>` / `<api-url>` 是占位符。
- **`scoped_interpreter` 的析构顺序**：必须晚于所有 `py::object`（如 `mImpl`）的析构，否则解释器已关闭还在释放 Python 对象会崩；注意对象声明顺序。
- **Python 依赖**：`llm/__init__.py` 需要 `openai` 包；CI 装 `python3-pytest` 是给 pybind11 的 `check` target 用，与 LLM 分支不是一回事。
- **`pybind11_DIR` 路径**：`config.cmake` 里是 `${YatCC_PYBIND11_DIR}/install/share/cmake/pybind11`，环境变量未传到 CMake 时会找不到（CI 已加 `$ENV{}` 回退）。
