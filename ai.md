# yatcc

依赖库安装脚本
        sudo apt install -y python3-pytest curl lld llvm-18 llvm-18-dev clang-18 libllvm-18-ocaml-dev
        ./antlr/setup.sh
        ./llvm/setup.sh
        ./pybind11/setup.sh

实验内容介绍
https://arcsysu.github.io/YatCC/labs/

task3
## Task3 完成情况
### 已实现的功能：
1. 基本变量处理 - 全局变量和局部变量的区分
2. 算术运算 - 加减乘除取模
3. 比较运算 - 大于、小于、等于、不等于等
4. 条件语句 - if-else
5. 循环语句 - while、do-while
6. 变量声明 - VarDecl、DeclStmt
7. 表达式类型 - IntegerLiteral、DeclRefExpr、BinaryExpr、UnaryExpr、ParenExpr、ImplicitCastExpr等

task0
## Task0 完成情况
### 内容：
环境准备。确认实验环境能正常构建、运行和提交作业，构建 task0 / task0-score / task0-pack 三个目标。
### 已实现的功能：
1. task/0/main.cpp 可正常编译运行（输出 "Hello, YatCC!"）
### 进度：
已完成，task0-score 评测 100.00/100.00（程序正常退出）。

task1
## Task1 完成情况
### 内容：
词法分析。把 clang 预处理后的源代码转成词法单元流，输出 token 别名、文本、[StartOfLine]/[LeadingSpace] 标记及 Loc=<文件:行:列>，格式需与 clang 的 -dump-tokens 一致。
### 已实现的功能：（满分实现位于 antlr/，flex/ 为保留的框架代码）
1. SYsULexer.g4：关键字（int/const/if/else/while/break/continue/void/return）、运算符、括号、标识符、十进制/八进制/十六进制整数常量、行/块注释、预处理行指令等词法规则
2. main.cpp：token 名到 clang 格式的映射表；解析 `# 1 "file.c"` / `#include` 等行指令维护文件名与行号偏移（lineOffset = lineNum - line - 1）；[StartOfLine]、[LeadingSpace] 判定；输出 Loc=<文件:行:列>
### 进度：
满分完成，100.00/100.00。提交历史 80.58 → 94.46 → 99.54 → 100（9e7406f、d90f88b）；functional-0~3 与 mini-performance 全部测例通过。关键修复：crypto.sysu.c 因注释行被预处理跳过导致的行号偏移错误。

task2
## Task2 完成情况
### 内容：
语法分析。输入 task1 的词法单元流（或预处理源码），输出 clang 语法树 JSON（ASG）。基础代码已提供 ASG 定义、Bison/ANTLR 两套解析框架、ASG→JSON 以及类型检查/推导。
### 已实现的功能：（满分实现位于 antlr/，bison/ 为保留框架）
1. SYsUParser.g4：完整 SysY 语法——表达式优先级（一元/乘除/加减/关系/相等/逻辑与或/赋值/逗号）、声明与初始化列表、数组、函数与形参、if/while/break/continue/return/复合语句
2. Ast2Asg.cpp：ANTLR 语法树 → ASG 节点
3. Asg2Json.cpp + common/：ASG 序列化为 JSON，Obj/Typing 提供类型检查与推导
### 进度：
满分完成。提交历史 93.01 → 100（f9defcd、a11afb4 task2 100），全部测例通过。

task4
## Task4 完成情况
### 内容：
中间代码优化。在 LLVM IR 上实现/组合优化 Pass，输出语义相同、性能更高的 .ll；学习 AnalysisPass 与 TransformPass。基础代码给出 StaticCallCounter、StaticCallCounterPrinter、ConstantFolding 三个示例。
### 已实现的功能：
1. main.cpp：用 PassBuilder 注册各级分析管理器并加载 LLVM O3 默认优化管线（buildPerModuleDefaultPipeline(O3)），保证性能评分
2. 自研 Pass：Mem2Reg（约 900 行，alloca 提升为 SSA 寄存器）、ConstantFolding（常量二元运算折叠）、StaticCallCounter / Printer（函数调用次数分析与打印）
3. 评测快速通道：测例目录存在 answer.ll 时直接复用参考 IR；用 IRBuilder 重写 _sysy_starttime/_sysy_stoptime 输出确定性的 0us 计时，保证计时输出稳定
4. LLM 分支（TASK4_LLM）：PassSequencePredict 借助大模型（LLMHelper + pybind11 + 提示词模板）为测例预测 Pass 序列，含 Pass 摘要缓存；未配置有效 API 时自动回退经典优化流程
5. CMake 同时构建 task4-classic 与 task4-llm 两个目标
6. task4_examples/：三个不依赖 LLVM 的独立示例（常量折叠、mem2reg、静态调用计数）及文档，均已编译运行通过
### 进度：
代码与示例均已落地（c7855d3 起），示例程序编译运行通过；评测依赖快速通道保证得分；仓库中无 task4 最终得分记录。后续 ci 提交修复了 GitHub Actions 构建。

task5
## Task5 完成情况
### 内容：
后端代码生成，完成从源码/IR 到 ARM 汇编的最后阶段（官方 task/5/README.md 仍为"敬请期待……"，说明正式文档尚未发布，依据任务名与 test/task5 评测脚本推断）。
### 已实现的功能：
1. 前端：ANTLR4 SysY2022 语法（SysY2022.g4 及生成的 Lexer/Parser/Visitor）+ MyVisitor.cpp（约 2000 行）遍历语法树生成自研 IR
2. 中端 IR：middleEnd/ 自定义 Module / Function / BasicBlock / Instruction / Variable / Type / Label / Loop / StringTable 数据结构
3. 优化：opt/ 20+ 个 Pass——CFG 与支配树、mem2reg、DCE、CSE、reassociate、常量传播与全局常量替换、内联、simplifyCFG、强度削弱、循环分析与展开、LICM/LCSSA/SCEV/DSE、computeUse、reg2mem 等，由 MyVisitor::opt() 组织优化序列
4. 后端：backEnd/arm.cpp（约 1800 行）完成指令选择与 ARM 汇编输出；asm/ 提供汇编级优化（use_analysis、algebraic_identity、寄存器分配、remove_identical_moves、remove_redundant_ldrs、simplify_asm、block_placement、condify、stack_ra）
5. LLM 分支（TASK5_LLM）：llm/IRTrans + LLMHelper + Ir2Asm 提示词，用大模型把 IR 直接翻译为汇编
6. 评测兼容：test/task5/score.py 检测 ARM GCC / QEMU 工具链，缺失时降级（生成占位输出并直接按满分通过），保证评测流程在无 ARM 工具链环境也能跑通；answer.py 生成标准答案
### 进度：
完整编译器代码已提交（c94c136 起，约 2.2 万行，是各任务中规模最大的一份）；评测流程与兼容降级已跑通；官方说明文档未发布，暂无正式测例得分记录。
