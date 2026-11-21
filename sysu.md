# SYsU / SysY —— 语言版本与本项目用到的版本

> 本文回答两个问题：**截至 2026-11-21 的最新版规范是什么**、**本项目实际用的是哪一版**。
> 相关背景见 `antlr.md`（语法文件）、`llvm.md`（clang 生成标准答案）、`cmake.md`（task0-answer 预处理）。

## 一句话结论

- **当前最新版（2026 年 11 月）**：`SysY2026`，用于 2026 年全国大学生计算机系统能力大赛编译系统设计赛（华为毕昇杯），相对 2022 版的主要新增是 **float 之外的向量类型**。
- **本项目用的不是最新版**，而是两套并存：
  - task0–task4 的测例与框架：YatCC 自定义的 **`SYsU`**（int-only 的 C 子集，源文件 `.sysu.c`），运行时库按 `__SYSY 202203L` 编译；
  - task5 前端：**`SysY2022` 官方文法**（`int` + `float`），见 `task/5/frontEnd/SysY2022.g4`。

## 名词澄清：SysY 与 SYsU 不是一回事

| | SysY | SYsU（本项目） |
|---|---|---|
| 来源 | 全国大学生计算机系统能力大赛「编译系统设计赛」官方定义的 C 子集 | 中山大学 arcsysu/YatCC 教学实验自定义变体 |
| 源文件 | 单文件 `.sy`（2026 年写作 `.sysy`），不含 `#include` | `.sysu.c`，**允许 `#include` 与预处理指令** |
| 预处理 | 无，编译器自己从源码开始 | `clang -E` 预处理后才是各 task 的真正输入（`task0-answer`） |
| 标准答案 | 运行输出与 GCC 比对 | **由 clang 生成**：`-cc1 -dump-tokens`、AST JSON、`-S -emit-llvm` |
| I/O | `libsysy.a` 的 `getint/putint/...` | `sylib.h` + `test/rtlib/include/sysu/*.h` 的 `sysu_*` 精简 libc |

因此 task1/2/3 的输出格式必须**对齐 clang 而不是自己定义**：token 别名（`l_paren`、`numeric_constant`）、`Loc=<文件:行:列>`、ASG JSON 结构都以 clang 为准。这也是 `SYsULexer.g4` 里要专门写 `LineDirective` 规则解析 `# 1 "file.c"` 的原因（`antlr.md`）。

## 版本演进（只列有明确出处的节点）

| 版本 | 年份 | 关键变化 |
|---|---|---|
| SysY（初版） | 2021 | C 子集：仅 32 位 `int` 与元素为 int 的多维数组；有函数/数组/if/while，但**无 `for`、无指针/结构体/switch/goto**；运算符优先级、结合性、短路求值与 C 一致；运行时库提供 `getint/putint/getch/putch/getarray/putarray/starttime/stoptime` |
| **SysY2022**（V1，`202203`） | 2022 | 新增 **`float` 类型**、float 数组、浮点字面量与 float 版运行时函数；`BType → 'int' \| 'float'`、`FuncType → 'void' \| 'int' \| 'float'`、`Number → IntConst \| FloatConst`。中科大《SysY 语言概要 / SysY2022 语言定义-V1》即此版 |
| **SysY2026** | 2026（当前最新） | 在 2022 边界上明确加入**向量类型**；技术方案第 23 条列出：全局变量声明、自定义函数、`int` 及 int 多维数组、`float` 及 float 多维数组、向量类型、赋值/表达式/语句块/常见控制流 |

> 2023–2025 各届的规范文档按届发布，历年细节以当年技术方案为准；上表只列有明确规范出处的版本。

## 2026 年 11 月最新版：SysY2026

**出处**：2026 年全国大学生计算机系统能力大赛编译系统设计赛（华为毕昇杯）「编译系统实现赛道技术方案」，第 23 条；大赛技术平台 https://compiler.xtnl.org.cn/#/ 。

**语言特性**（第 23 条原文要点）：

- 语法与语义主要参考 C 语言基本语法规范
- 支持全局变量声明、自定义函数
- `int` 类型与元素为 `int` 的多维数组类型
- `float` 类型与元素为 `float` 的多维数组类型
- **向量类型**（相对 SysY2022 最主要的新增）
- 赋值、表达式、语句块、常见控制流结构；表达式支持基本算术、关系、逻辑运算，优先级与结合性和 C 一致

**工具链与赛制**（第 25–27 条，与本项目差异最大）：

- 目标平台：ARMv8-A 64 位（Cortex-A53，`gcc -march=armv8-a`）或 RISC-V 64GC（BOOM v3，`gcc -march=rv64gc`）
- 编译环境：Ubuntu 24.04、LLVM/Clang-18、`clang++ --std=c++17 -O2 -lm`
- 调用形式：`compiler testcase.sysy -S -o testcase.s`，性能测评加 `-O1`
- 初赛功能 50% + 性能 50%；**决赛现场公布语言语法 / 目标平台 / 测评基准的变更**（第 3、10、24 条），要求现场调整编译器

**需要注意的不确定点**：部分 2026 参赛队的公开文档把初赛公开用例的语言边界描述为「SysY2022」（不含向量类型），把向量类型视为扩展或决赛内容，与技术方案第 23 条的字面表述不完全一致。以大赛网站发布的《SysY2026 程序设计语言规范、文法及说明》（第 29 条）为准，决赛前务必重新核对。公开实现里出现的向量形态（`vector` 定长同元素类型、逐元素算术、标量广播、`vsum`、一维下标、不能进条件表达式）来自参赛项目而非官方规范原文，仅作参考。

## 本项目用到的版本

### 1) SYsU —— task0–task4 的输入语言

- 源文件 `test/cases/**/*.sysu.c`：先 `clang -E` 生成带 `#line` 的预处理结果，才是 task1~task3 真正读入的内容（`ai.md`「CMake 各 target 作用」）。
- 语法：`task/1/antlr/SYsULexer.g4`、`task/2/antlr/SYsUParser.g4`（另有 flex / bison 两套框架）。
  - 类型只有 `int`、`void`，**没有 float、没有向量**
  - 有 `const`、多维数组、函数与形参、初始化列表
  - 整数常量支持十进制 / 八进制 / 十六进制；行注释、块注释、`LineDirective`
  - 语句：`if/else`、`while`、`break`、`continue`、`return`、复合语句、表达式语句
- 支持 `#include`：`test/rtlib/include/sysu/` 提供 `sysu_open`、`sysu_getchar`、`sysu_puts`、`sysu_atoi`、`sysu_exit` 等精简 libc 声明（`sysu/fcntl.h`、`stdio.h`、`stdlib.h`、`string.h`、`unistd.h`）。
- 运行时库 `test/rtlib/include/sysy/sylib.h`：`starttime()/stoptime()`、`getint/putint`、`getch/putch`、`getarray/putarray`；`test/rtlib/sysy/sylib.cc:1` 定义 **`#define __SYSY 202203L`**，`sylib.h:39` 由 `#if __SYSY >= 202203L` 启用 `getfloat/putfloat/getfarray/putfarray/putf`。即**运行时库是 SysY2022（202203）版，但 SYsU 语言本身不支持 float**，这些 float 接口在 SYsU 测例里用不上。

### 2) SysY2022 —— task5 前端

- `task/5/frontEnd/SysY2022.g4` 是项目里唯一按官方 2022 文法写的语法文件：`bType: 'int' | 'float'`、`funcType: 'void' | 'int' | 'float'`、`FloatConst`（含十六进制 `p/P` 指数形式）、`constDecl`/`varDecl` 的嵌套初始化列表、短路 `&&`/`||`/`!`。
- `task/5/main.cpp:34-35` 用正则去掉 `#include` 后交给 ANTLR，`MyVisitor` 生成自研 IR，再由 `backEnd/` 输出 ARM 汇编。
- 所以 task5 是**独立于 SYsU 测例的另一条链路**：语言更接近官方 SysY2022，而非 task1–4 的 clang 对齐路线。

### 3) 版本对照

| 维度 | SysY2026（最新） | SysY2022（task5） | SYsU（task1–4） |
|---|---|---|---|
| 基本类型 | `int`、`float`、向量 | `int`、`float` | `int`（`void` 仅函数返回） |
| 多维数组 | int / float 数组 | int / float 数组 | int 数组 |
| `const` | 支持 | 支持 | 支持 |
| 源文件 | `.sysy` | `.sy` | `.sysu.c` |
| 预处理 | 无 | 无 | `clang -E` + `#line` |
| 标准答案 | 运行输出比对 | 运行输出比对 | clang token / AST JSON / IR |
| 目标平台 | ARMv8-A 或 RISC-V 64GC | ARM（本项目） | LLVM IR → x86（评测） |
| 运行时 | 大赛 SysY runtime | `sylib.h`（`__SYSY=202203L`） | `sylib.h` + `sysu_*` 精简 libc |

## 若要升级到 SysY2026 需要补什么

1. **float 全链路**：task1/2 的词法与语法（`SYsULexer.g4` 加 `FloatConst`/`float`）、类型检查（`Typing.cpp`）、task3 的 `IRBuilder` 浮点指令、task5 后端 NEON/浮点寄存器与调用约定。
2. **向量类型**：语法、类型系统、逐元素运算、标量广播、`vsum`、下标访问、不能进条件表达式的约束。
3. **运行时**：`sylib.h` 已声明 `getfloat/putfloat/getfarray/putfarray/putf`，但 SYsU 语法与评测脚本尚未接入。
4. **RISC-V 分支**：项目 task5 目前只生成 ARM 汇编。
5. **赛制适配**：`compiler xxx.sysy -S -o xxx.s` 的命令行、`-O1` 性能档、决赛现场变更。

## 参考

- YatCC 实验内容：https://arcsysu.github.io/YatCC/labs/（本仓库 `ai.md:10`）
- 2026 大赛技术平台：https://compiler.xtnl.org.cn/#/ （技术方案第 28–29 条）
- 《SysY 语言概要 / SysY2022 语言定义-V1》：`https://cscourse.ustc.edu.cn/vdir/Gitlab/compiler_staff/jianmu-supplemental/-/raw/master/SysY2022%E8%AF%AD%E8%A8%80%E5%AE%9A%E4%B9%89-V1.pdf`
- 仓库内一手证据：`task/5/frontEnd/SysY2022.g4`、`test/rtlib/include/sysy/sylib.h`、`test/rtlib/sysy/sylib.cc`、`test/rtlib/include/sysu/`
