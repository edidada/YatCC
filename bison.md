# Bison —— 本项目用到的知识点

> 版本/安装见 `ai.md`「三方库」：3.8.2（系统预装），`find_package(BISON 3.8)` 在 `task/CMakeLists.txt:2`。
> 配套：`flex.md` 提供词法器；`antlr.md` 是 task2 的另一套（满分）实现。

## 在本项目中的位置

| 位置 | 作用 |
|---|---|
| `task/2/bison/par.y` | task2 语法规则 + 语义动作（约 518 行） |
| `task/2/bison/par.hpp` / `par.cpp` | `par::Symtbl` 符号表、`par::gMgr` 节点池、`Decls`/`Exprs` 容器 |
| `task/2/bison/lex.l` / `lex.cpp` | 词法器，向 bison 提供 token |
| `task/2/bison/main.cpp` | 驱动 + ASG→JSON 输出 |
| `task/2/bison/CMakeLists.txt:8-20` | `flex_target()` + `bison_target()` |
| `task/2/common/asg.hpp` / `Asg2Json.cpp` | ASG 节点定义与序列化 |

## 需要掌握的知识点

1. **`.y` 结构** —— `%{ %}`、`%union`、`%type`、`%token`、`%start`、`%%` 规则段、`%%` 用户代码。`task/2/bison/par.y:8-27` 的 `%union` 把 ASG 节点指针（`TranslationUnit*`、`Expr*`、`Stmt*`…）与 `std::string*` 等放进同一个联合。

2. **`%type` / `%token` 绑定 union 成员** —— `%type <Expr> additive_expression ...`、`%token <RawStr> IDENTIFIER CONSTANT`（`par.y:30-48`）。这样 `$$` / `$1` 才有正确类型，写错会编译期报 union 成员不匹配。

3. **语义动作 `$$` / `$1`** —— `$$` 是当前非终结符的语义值，`$n` 是第 n 个符号；`translation_unit` 的动作把 `external_declaration` 的 `Decls*` 逐个 push 进 `TranslationUnit->decls`（`par.y:69-86`）。位置信息用 `@$` / `@n`（本项目未用）。

4. **构造 ASG 而非直接求值** —— 动作用 `par::gMgr.make<asg::FunctionDecl>()` 申请节点、`dynamic_cast`/`dcst<>` 判断声明种类，并把 `par::gCurrentFunction` 设为当前函数以便后续语句挂到函数体上（`par.y:96-120`）。`par::Symtbl` 负责作用域内的名字查找。

5. **优先级与结合性** —— 可以用 `%left` / `%right` / `%nonassoc` + `%prec`；本项目与 ANTLR 版一样靠**分层规则**（`unary → multiplicative → additive → relational → equality → logical_and → logical_or`，规则定义见 `par.y:361-395`）表达，不在 bison 里声明优先级（`%type` 声明见 `par.y:30-48`）。

6. **`%start start` 与起始动作** —— `start` 规则的第一个动作里 `new par::Symtbl()`，解析完 `delete`（`par.y:53-67`），即"在语法规则里做初始化/收尾"。

7. **CMake 集成** —— `find_package(BISON 3.8)` + `bison_target(<name> <.y> <out.cc> DEFINES_FILE <out.hh>)`，产物 `BISON_<name>_OUTPUTS` 与 `FLEX_<name>_OUTPUTS` 一起加进 `add_executable`（`task/2/bison/CMakeLists.txt:1-20`）；缺 FLEX/BISON 会 FATAL_ERROR。

8. **与 ASG/JSON 的衔接** —— 语法树节点在语义动作里直接构造为 `asg::*`，`main.cpp` 再调 `Asg2Json` 输出 clang 风格 JSON；类型检查在 `task/2/common/Typing.cpp`。

## 容易踩的坑

- **bison 3.8 与 2.3 语法差异** —— `%code` 等指令、旧版 `%pure-parser` 写法不同；仓库根 `install_bison.sh` / `bison_install_success.md` 是 macOS 从源码装 3.8.2 的备用方案，WSL/Ubuntu 直接 apt。
- **`%union` 里放裸指针要管生命周期** —— 项目用 `par::gMgr` 统一托管节点、容器用完 `delete`（`par.y:73`、`:83`），避免悬垂。
- **shift/reduce 冲突** —— 用 `bison -v` 生成 `par.output` 检查；改分层规则通常比堆 `%prec` 更可控。
- **当前 `TASK2_WITH` 可切到 antlr**：切换实现必须换 build 目录（CMake 缓存里的 `add_subdirectory` 分支不同），见 `cmake.md`。
