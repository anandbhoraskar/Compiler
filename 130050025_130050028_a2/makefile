all:    distclean Scanner.ih Scanner.h Scannerbase.h lex.cc parse.cc main.cc Parser.h Parserbase.h Parser.ih
	g++   --std=c++0x lex.cc parse.cc main.cc -o parser
	rm -f symtab ast mips.s
	./parser < test.c
        
Scanner.ih: lex.l
	if [ ! -e Scanner.ih ]; then \
		flexc++ lex.l;\
                sed -i '/include/a #include "Parserbase.h"' Scanner.ih; \
	fi

parse.cc Parser.h Parserbase.h Parser.ih: parse.y
	bisonc++  --construction parse.y; 
	sed -i '/$insert preincludes/a #include "ast.h"' Parserbase.h;
	sed -i '/$insert preincludes/a #include "symboltable.cpp"' Parserbase.h;
	sed -i '\|STYPE__     d_val__;| d' Parserbase.h;
	sed -i '\|typedef Meta__::SType STYPE__;| a \\tpublic: static STYPE__  d_val__; ' Parserbase.h;
	sed -i '/include "Parser.ih"/a #include "ast.cpp"' parse.cc;
	sed -i '/#include/a vector<StmtAst*> astQueue;' Parser.ih;
	sed -i '/#include/a SymbolTable* gst = new SymbolTable();' Parser.ih;
	sed -i '/#include/a SymbolTable* st = new SymbolTable();' Parser.ih;
	sed -i '/#include/a Symbol* tempSymbol;' Parser.ih;
	sed -i '/#include/a Type* type;' Parser.ih;
	sed -i '/#include/a stack<Type*> typeStack;' Parser.ih;
	sed -i '/#include/a int indexArray = 0;' Parser.ih;
	sed -i '/#include/a int tempSize;' Parser.ih;
	sed -i '/#include/a int gotError = 0;' Parser.ih;
	sed -i '/#include/a int lOffset = 8;' Parser.ih;
	sed -i '/#include/a int inStruct = 0;' Parser.ih;
	sed -i '\|void Parser::print__()| i Meta__::SType ParserBase::d_val__; ' parse.cc


.PHONY: clean distclean 
clean:
	$(RM) Parser.ih Parser.h Parserbase.h parse.cc Scanner.ih Scanner.h Scannerbase.h lex.cc a.out graph.ps junk symtab ast *~

distclean: clean
	$(RM) parse.y.output parser