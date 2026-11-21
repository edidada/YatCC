# Flex —— 本项目用到的知识点

> 版本/安装见 `ai.md`「三方库」：2.6.4（系统预装），`find_package(FLEX 2.6)` 在 `task/CMakeLists.txt:1`。
> 配套：`antlr.md` 是 task1 的另一套（满分）实现；`bison.md` 是 task2 的语法分析器。

## 在本项目中的位置

| 位置 | 作用 |
|---|---|
| `task/1/flex/lex.l` | task1 词法规则 |
| `task/1/flex/lex.hpp` / `lex.cpp` | `Id` 枚举、`G` 状态、`id2str()`、`come()` |
| `task/1/flex/main.cpp` | `yyin` 输入 + `while(yylex())` 主循环 + `print_token()` |
| `task/1/flex/CMakeLists.txt:5-8` | `flex_target()` 生成 `lex.l.cc` / `lex.l.hh` |
| `task/2/bison/lex.l` | task2 bison 分支的词法器（喂给 bison） |

## 需要掌握的知识点

1. **`.l` 三段结构** —— `%{ ... %}`（C/C++ 头代码）、定义段（命名正则）、`%%` 规则段、`%%` 用户代码段。`task/1/flex/lex.l:1-16` 里 `%{ %}` 定义 `ADDCOL()` / `COME(id)` 两个宏。

2. **`%option`** —— `8bit warn noyywrap yylineno`：`noyywrap` 免去自己写 `yywrap()`，`yylineno` 让 flex 自动维护行号（`lex.l:11`）。

3. **命名正则与字符集** —— `D [0-9]`、`L [a-zA-Z_]`、`IS ((u|U)|...)`，规则里用 `{D}`、`{L}` 引用（`lex.l:13-15`）。最长匹配、先定义优先，关键字规则要写在 `{L}({L}|{D})*` 之前。

4. **规则动作与内置变量** —— `yytext`（匹配文本）、`yyleng`（长度）、`yylineno`（行号）；`ADDCOL()` 用 `g.mColumn += yyleng` 累加列，`COME(id)` 调 `return come(id, yytext, yyleng, yylineno)`（`lex.l:7-8`、`lex.cpp:34-45`）。

5. **`yylex()` 驱动** —— flex 生成 `yylex()`，`yyin` 指向输入 `FILE*`，主循环 `while (yylex()) ;` 直到返回 0（`task/1/flex/main.cpp:71-90`）。`<<EOF>>` 是特殊规则（`lex.l:47`）。

6. **跳过 vs 返回** —— 预处理行 `^#[^\n]*` 和空白 `[ \t\v\n\f]` 用 `return ~YYEOF;`（非零、不产生 token）跳过；解析 `#line` 才能拿到文件名/行号（`lex.l:43-45`）。

7. **token 编号与名称表** —— `lex.hpp` 的 `enum Id` 定义 `INT`、`RETURN`、`IDENTIFIER` 等（前几个编号与 bison 内部保留值对齐：`YYEMPTY=-2`、`YYEOF=0`、`YYerror=256`、`YYUNDEF=257`），`lex.cpp:9-15` 的 `kTokenNames` 按同一顺序给出输出别名，`id2str()` 做转换。

8. **CMake 集成** —— `find_package(FLEX 2.6)` + `flex_target(<name> <.l> <output.cc> DEFINES_FILE <output.hh>)`，产物通过 `FLEX_<name>_OUTPUTS` / `FLEX_<name>_OUTPUT_HEADER` 加到 `add_executable`（`task/1/flex/CMakeLists.txt:1-11`）。分支未启用时会 `message(FATAL_ERROR "没有找到 Flex ！")`。

## 容易踩的坑

- **Loc 列号要自己维护**：flex 只给 `yyleng`，没有列号；`G` 里的 `mColumn`、`mStartOfLine`、`mLeadingSpace` 都要手工更新（`lex.cpp:40-42`）。
- **当前 `print_token()` 输出的是 `Loc=<0:0>`**（`task/1/flex/main.cpp:59`），属于基础代码框架，未实现文件名/行号；满分实现在 `task/1/antlr/`，见 `antlr.md`。
- **`#line` 行指令必须解析**：预处理后源码的行号与原文件不同，`clang -E` 输出里的 `# 1 "file.c"` 才是映射依据（task1 满分实现就卡在这个偏移上）。
- **切换实现要换 build 目录**：`TASK1_WITH` 决定 `add_subdirectory(flex)` 还是 `add_subdirectory(antlr)`，见 `cmake.md`。
