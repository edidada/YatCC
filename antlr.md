# ANTLR —— 本项目用到的知识点

> 版本/安装见 `ai.md`「三方库」：4.13.2（生成器 jar + C++ runtime），由 `antlr/setup.sh` 装到 `antlr/install`。
> 配套：`flex.md`、`bison.md` 是 task1/task2 的另一套实现。

## 在本项目中的位置

| 位置 | 作用 |
|---|---|
| `task/1/antlr/SYsULexer.g4` | task1 词法规则（`lexer grammar`） |
| `task/1/antlr/main.cpp` | 遍历 token 流，输出 clang `-dump-tokens` 格式 |
| `task/2/antlr/SYsUParser.g4` | task2 语法规则（`parser grammar`） |
| `task/2/antlr/Ast2Asg.cpp` | 语法树 → ASG |
| `task/2/antlr/SYsULexer.py` | `.tokens` → C++ 头文件 `SYsULexer.tokens.hpp` |
| `task/5/frontEnd/SysY2022.g4` + `MyVisitor.cpp` | task5 前端，Visitor 遍历语法树生成自研 IR |
| `task/2/antlr/CMakeLists.txt:6` | `antlr4_generate()` 把 .g4 编译成 C++ 源码 |

## 需要掌握的知识点

1. **两类 .g4 与 tokenVocab** —— `lexer grammar` 只产生 token；`parser grammar` 用 `options { tokenVocab=SYsULexer; }` 复用词法器的 token 表（`task/2/antlr/SYsUParser.g4:1-5`）。生成器由 Java 跑 jar，运行期链接 `antlr4_static`。

2. **`fragment` 与正则语法** —— `fragment` 规则只被其他规则引用、不产生独立 token；字符集 `[0-9]` `[a-zA-Z_]`、取反 `~["\r\n]`、非贪婪 `.*?`、量词 `+ * ?` 见 `task/1/antlr/SYsULexer.g4:3-16`。`-> skip` 直接丢弃（Newline，`:132`），`Whitespace` 则保留成 token 以便判断 `[LeadingSpace]`。

3. **最长匹配 / 先定义优先** —— 关键字必须写在 `Identifier` 之前；`0[0-7]*` 与 `[1-9][0-9]*` 的先后决定八/十进制常量归属。

4. **表达式优先级靠分层规则** —— ANTLR 没有 `%prec`，项目用 `primary → postfix → unary → multiplicative → additive → relational → equality → logicalAnd → logicalOr → assignment → expression` 逐层左递归表达优先级（`task/2/antlr/SYsUParser.g4:7-65`）。

5. **C++ Runtime 基本流水线** —— `ANTLRInputStream` → `SYsULexer` → `CommonTokenStream.tokens.fill()` → `tokens.getTokens()`（`task/1/antlr/main.cpp:342-348`）。常用 `Token::getType()/getLine()/getCharPositionInLine()/getText()`，`lexer.getVocabulary().getSymbolicName(type)` 取别名（`:282`）。

6. **Visitor 模式** —— 生成 `SysY2022BaseVisitor`，派生类重写 `visitXxx(...)`，返回 `antlrcpp::Any`，`visitChildren(ctx)` 继续向下遍历（`task/5/frontEnd/MyVisitor.h:24`、`MyVisitor.cpp:98`）。Listener 模式本项目未用。

7. **CMake 集成** —— `find_package(antlr4-runtime 4.13)` / `find_package(antlr4-generator 4.13)`（`task/CMakeLists.txt:4-5`）；`config.cmake:36-38` 给出两个 `xxx_DIR` 与 `ANTLR4_JAR_LOCATION`；`antlr4_generate()` 输出加到 `ANTLR4_SRC_FILES_<name>`。生成器内部 `find_package(Java)`，必须有 Java。

## 容易踩的坑

- **行号不是源码行号**：`getLine()` 是预处理后文件的行号。task1 靠解析 `# 1 "file.c"` 行指令维护 `lineOffset = lineNum - line - 1`，再算出 `Loc=<文件:行:列>`（`task/1/antlr/main.cpp:222-270`）；注释行被预处理跳过时最容易错。
- **token 别名要自己映射**：ANTLR 的符号名（`Int`、`LeftParen`）与 clang 的 `int`、`l_paren` 不同，靠 `unordered_map` 转换（`task/1/antlr/main.cpp:178-206`）。
- **cpp-runtime 自带 googletest**：默认 `ANTLR_BUILD_CPP_TESTS=ON` 会 FetchContent 旧版 googletest，其 `cmake_minimum_required(VERSION 2.8.12)` 被 CMake 4.x 拒绝；`antlr/setup.sh` 已加 `-DANTLR_BUILD_CPP_TESTS=OFF`。
- **切换实现要换 build 目录**：`TASK1_WITH` 决定 `add_subdirectory(flex)` 还是 `add_subdirectory(antlr)`，CMake 缓存会冲突，CI 用 `build-flex` / `build-antlr` 分开。
