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

CMake targets
## CMake 各 target 作用
基于构建目录 cmake-build-debug-wsl24_clang 的 `cmake --build . --target help`，以及 test/*/CMakeLists.txt、task/CMakeLists.txt。下文 `<build>` 即该构建目录。

### 编译程序
1. task0~task5：各实验的可执行文件。task1/task2 由 config.cmake 的 TASK1_WITH / TASK2_WITH 决定走 flex/bison 还是 antlr 分支（当前均为 antlr）；task4/task5 是聚合 target，分别依赖 task4-classic + task4-llm、task5-classic + task5-llm
2. task4-classic / task4-llm、task5-classic / task5-llm：经典实现与 LLM 实现两个可执行程序
3. examples 及 01_constant_folding / 02_mem2reg / 03_static_call_counter：不依赖 LLVM 的独立示例
4. test-rtlib：用 clang++ 把 test/rtlib 编成 `<build>/test/libtest-rtlib.so`，供评测链接

### 生成测例源文件与答案
5. task0-answer：对 test/cases/*.sysu.c 逐个执行 clang -E（test/task0/answer.py），结果写到 `<build>/test/task0/<case>`。**后续各实验真正读入的是这份预处理后的源文件**（含 #line 行指令、展开的 sylib.h），不是 test/cases 下的原始 .sysu.c；手动跑 task1 时输入必须用它，Loc 里的绝对路径才能对上答案
6. task0-diy-answer：同上，针对 test/diy-cases/*.sysu.c，输出到 `<build>/test/task0/diy-cases/<case>`，带 --no-cache 禁用缓存
7. task1-answer~task5-answer：各实验标准答案（如 task1 用 clang -cc1 -dump-tokens 生成 `<build>/test/task1/<case>/answer.txt`）；依赖 task0-answer、test-rtlib，复活时还依赖上一实验的 answer
8. task1-diy-answer / task2-diy-answer：diy 测例标准答案

### 评分
9. task0-score~task5-score：跑对应 score.py，借 ctest 逐测例运行程序、与答案比对并给分。**task1-score 就是实验一评分**，依赖 task1（编译）+ task1-answer（答案），并间接依赖 task0-answer（生成预处理源文件）；CI 的 score 步骤即依次构建这 5 个 target
10. task2-diy-score：diy 测例评分

### 打包交作业
11. task0-pack~task5-pack：把 task/N 目录打成 `<build>/taskN-<学号>-<姓名>.tar.xz`

### 其他
12. all / clean / test / edit_cache / rebuild_cache / help 及 Nightly*/Continuous*/Experimental*：CMake/CTest 内置，不用管

### 001_002_crypto.sysu.c 与 task1 参数
- test/diy-cases/001_002_crypto.sysu.c.out 是 task1 的标准答案（clang -dump-tokens 格式，1056 行）；对应输入是 test/cases/mini-performance/crypto.sysu.c 经 clang -E 预处理后的内容。原仓库没有 001_002_crypto.sysu.c 这个源文件，现已按 `<build>/test/task0/mini-performance/crypto.sysu.c` 补到 test/diy-cases/（4KB，以 `# 1 "..."` 行指令开头）
- task1 参数：`task1 <input> <output>`（task/1/antlr/main.cpp:324）；argv[2] 是输出文件且被 ofstream 覆盖，绝不能传 .out 答案文件

三方库
## 项目用到的三方库
版本以本仓库当前 WSL 环境（cmake-build-debug-wsl24_clang）实配为准。三个自编译依赖由仓库根各目录的 setup.sh 装到各自的 install/，再由 config.cmake 的 YatCC_ANTLR_DIR / YatCC_LLVM_DIR / YatCC_PYBIND11_DIR（不带 /install）指向。

### flex
1. 版本 2.6.4（/usr/bin/flex）；`find_package(FLEX 2.6)` 见 task/CMakeLists.txt:1
2. 来源：系统 apt / 预装，不经 setup.sh
3. 用途：task1 的 flex 分支，由 .l 规则生成 C 词法分析器；当前 config.cmake 的 TASK1_WITH = antlr，该分支未启用

### bison
4. 版本 3.8.2（/usr/bin/bison）；`find_package(BISON 3.8)` 见 task/CMakeLists.txt:2
5. 来源：系统 apt / 预装；仓库根的 install_bison.sh 是给 macOS 从源码编译 3.8.2 的备用脚本（WSL 用不到）
6. 用途：task2 的 bison 分支生成语法分析器；当前 TASK2_WITH = antlr，未启用

### antlr
7. 版本 4.13.2：antlr-4.13.2-complete.jar（Java 生成器）+ antlr4-cpp-runtime-4.13.2（C++ 运行时），由 antlr/setup.sh 下载并编译，装到 antlr/install
8. CMake 引入：`find_package(antlr4-runtime 4.13)` / `find_package(antlr4-generator 4.13)`（task/CMakeLists.txt:4-5）；config.cmake:36-38 指定两个 xxx_DIR 与 ANTLR4_JAR_LOCATION
9. 组成：生成期 antlr.jar + Java，链接期 antlr4_static 静态库；`antlr4_generate()` 宏把 .g4 编译成 C++ lexer/parser 源码
10. 用途：task1（SYsULexer.g4）、task2（SYsUParser.g4）、task5 前端（SysY2022Lexer/Parser）；cpp-runtime 附带 libgtest.a / libgmock.a，项目未直接使用
11. 依赖 Java 11.0.33（antlr4-generator 内部 find_package(Java)，跑 jar 必需）

### llvm / clang
12. 版本 18.1.8：由 llvm/setup.sh 从 llvm-18.1.8.src / clang-18.1.8.src / cmake-18.1.8.src 源码编译（Debug、X86、LLVM_BUILD_LLVM_DYLIB=ON、LLVM_USE_LINKER=lld），装到 llvm/install（约 21G，libLLVM.so.18.1 约 1.6G）
13. CMake 引入：config.cmake:41-46 给出 LLVM_DIR / LLVM_INSTALL_DIR / CLANG_EXECUTABLE / CLANG_PLUS_EXECUTABLE；task/CMakeLists.txt:11-17 定义 INTERFACE IMPORTED 目标 LLVM，链接 libLLVM.so
14. 用途：task2（llvm/Support/JSON 序列化 ASG）、task3（IRBuilder 生成 LLVM IR / Verifier）、task4（PassBuilder、Mem2Reg、ConstantFolding、StaticCallCounter 等 Pass）、task5（IR 与优化）；clang/clang++ 还被评测用于 task0-answer 的 clang -E 预处理、task1-answer 的 clang -cc1 -dump-tokens 生成标准答案，以及编译 test-rtlib
15. 系统另装了 apt 的 llvm-18 / clang-18（18.1.3），只作工具链/备用；项目实际链接的是源码编译的 18.1.8

### 其他三方依赖
16. pybind11 2.13.6：pybind11/setup.sh 安装，find_package(pybind11 2.13.6)；pybind11::embed 供 task4-llm / task5-llm 内嵌 Python 调用大模型
17. Python3 3.12.3：根 CMakeLists.txt:14 `find_package(Python3 COMPONENTS Interpreter Development REQUIRED)`，供评测脚本（common.py / answer.py / score.py）、SYsULexer.py 生成 tokens 头，以及 pybind11 embed
18. 构建与测试工具：CMake 3.28.3、Ninja 1.11.1、lld 18.1.3、CTest、GCC 13.3.0（编译 LLVM 源码）、系统 clang 18.1.3（当前项目 CMAKE_C/CXX_COMPILER）；CI 另装 python3-pytest（pybind11 的 check 用）与 curl

