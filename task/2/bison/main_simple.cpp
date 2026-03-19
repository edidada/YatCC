#include "Typing.hpp"
#include "lex.hpp"
#include "par.hpp"
#include <fstream>
#include <iostream>
#include <string>

extern int yydebug;
extern FILE* yyin;
int yyparse(void);

int
main(int argc, char* argv[])
{
  if (argc != 3) {
    std::cout << "Usage: " << argv[0] << " <input> <output>\n";
    return -1;
  }

  yyin = fopen(argv[1], "r");
  if (!yyin) {
    std::cerr << "Failed to open " << argv[1] << '\n';
    return -2;
  }

  std::ofstream outFile(argv[2]);
  if (!outFile) {
    std::cout << "Error: unable to open output file: " << argv[2] << '\n';
    return -3;
  }

  std::cout << "程序 " << argv[0] << std::endl;
  std::cout << "输入 " << argv[1] << std::endl;
  std::cout << "输出 " << argv[2] << std::endl;

  // 从源代码生成抽象语义图
  yydebug = 0; // 禁用 Bison 的调试输出
  if (auto e = yyparse())
    return e;
  par::gMgr.mRoot = par::gTranslationUnit;
  par::gMgr.gc();

  // 执行类型检查
  asg::Typing typing(par::gMgr);
  typing(par::gTranslationUnit);
  typing.mTypeCache.clear();
  par::gMgr.gc();

  // 简单输出 - 表示解析成功
  outFile << "Parse successful" << std::endl;

  fclose(yyin);
  return 0;
}
