# LLVM / Clang —— 本项目用到的知识点

> 版本/安装见 `ai.md`「三方库」：18.1.8，由 `llvm/setup.sh` 源码编译到 `llvm/install`（`libLLVM.so`）。
> 官方 IR 语法参考 https://llvm.org/docs/LangRef.html

## 在本项目中的位置

| 位置 | 作用 |
|---|---|
| `task/3/EmitIR.cpp` | ASG → LLVM IR（本任务核心） |
| `task/2/common/Asg2Json.cpp` | `llvm::json` 把 ASG 序列化成 clang 风格 JSON |
| `task/4/main.cpp` | PassBuilder + O3 管线 + 评测快速通道 |
| `task/4/ConstantFolding.cpp` / `Mem2Reg.cpp` / `StaticCallCounter.cpp` | 自定义 Pass |
| `task/CMakeLists.txt:11-17` | `add_library(LLVM INTERFACE IMPORTED)`，链接 `libLLVM.so` |
| `config.cmake:41-46` | `LLVM_DIR` / `LLVM_INSTALL_DIR` / `CLANG_EXECUTABLE` |

## 需要掌握的知识点

### IR 结构（task3）

1. **层次模型** —— `LLVMContext` → `Module` → `Function` → `BasicBlock` → `Instruction`；一切值都是 `Value*`，类型 `Type*`。
2. **`IRBuilder<>`** —— 几乎所有指令都由它创建：`CreateAdd/Sub/Mul/SDiv/SRem`、`CreateICmpEQ/NE/SLT/SGT/SLE/SGE`（`task/3/EmitIR.cpp:346-366`）、`CreateAlloca/Load/Store`（`:410`、`:461`、`:884`）、`CreateCall`（`:537`）、`CreateBitCast`（`:153`）、`CreateRet`（`:767`）。
3. **控制流 = 多个基本块** —— `BasicBlock::Create` + `CreateBr/CreateCondBr`。短路求值 `&&`/`||` 用 `land.rhs` / `land.merge`、`lor.merge` 块（`:370-397`）；`if-else` 用 `then/else/merge`（`:624-642`）；`while`、`do-while` 用 `cond/body/merge` 并配合 `mLoopBreakBb` / `mLoopContinueBb` 处理 break/continue（`:653-740`）。
4. **局部变量用 `alloca`** —— 栈上分配、Load/Store 访问；数组 `CreateAlloca(arrTy, ...)` + GEP 下标（`:884-916`）。后续 task4 的 Mem2Reg 就是把这些 alloca 提升成 SSA 寄存器。
5. **Opaque Pointers（LLVM 17+）** —— 指针无类型，一律 `ptr`；`PointerType::get(ctx, 0)`、`getInt32Ty`、`ConstantInt::get`、`ConstantDataArray::getString`、`ConstantExpr::getInBoundsGetElementPtr`（`task/4/main.cpp:149-191`）。
6. **读写与校验** —— `parseIRFile` + `SMDiagnostic` 读 `.ll`，`raw_fd_ostream` + `Module::print` 输出，`verifyModule` 校验（`task/4/main.cpp:127-141`、`:226-228`）。

### Pass 框架（task4）

7. **新 PassManager 四级管理器** —— `LoopAnalysisManager` / `FunctionAnalysisManager` / `CGSCCAnalysisManager` / `ModuleAnalysisManager`，`PassBuilder` 逐个 `register*Analyses` 并 `crossRegisterProxies`（`task/4/main.cpp:32-44`）。
8. **复用官方管线** —— `pb.buildPerModuleDefaultPipeline(OptimizationLevel::O3)` 保证性能评分（`:50`）；自定义 Pass 用 `mam.registerPass`、`mpm.addPass`。
9. **两类 Pass 的写法** —— Transform 继承 `PassInfoMixin<T>`，实现 `PreservedAnalyses run(Module&, ModuleAnalysisManager&)`（`task/4/ConstantFolding.hpp:7-15`）；Analysis 继承 `AnalysisInfoMixin<T>`，`Result run(...)`（`task/4/StaticCallCounter.hpp:7-11`）。
10. **IR 改写惯用法** —— `dyn_cast<BinaryOperator>` 判断指令、`ConstantInt` 取常量、`replaceAllUsesWith` 替换、`eraseFromParent` 删除（`task/4/ConstantFolding.cpp:18-33`）；Mem2Reg 则是遍历 alloca 的 users 判断可否提升（`task/4/Mem2Reg.cpp:5-27`）。

### Clang 工具链（评测用）

11. `clang -E` 预处理生成 task0-answer（后续实验真正读入的是这份带 `#line` 的文件）；`clang -cc1 -dump-tokens` 生成 task1 标准答案；`clang -S -emit-llvm` 生成 `answer.ll`；`clang++` 编译 `test-rtlib`。见 `test/task0/CMakeLists.txt`、`test/task1/CMakeLists.txt`。

## 容易踩的坑

- **LLVM 18 头文件与 GCC 15 不兼容**：`-Wtemplate-body` 对 `SmallVector` 报 "has no member named begin/end"。CI 已固定 `CC=gcc-14 CXX=g++-14`（`.github/workflows/cmake-single-platform.yml`）。
- **链接的是源码编译的 18.1.8**，不是 apt 的 18.1.3；`LLVM_INSTALL_DIR/include`、`/lib`、`/bin/clang` 都要指向同一份 install。
- **短路求值是 C 标准明确定义的语义**，不能简单用一个 `and` 指令糊过去，否则含副作用/除零的测例会挂。
- **`verifyModule` 必须在输出前跑**，IR 不合法时评分程序会直接崩。
