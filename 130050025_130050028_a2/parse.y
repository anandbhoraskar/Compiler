%polymorphic INT:int; FLOAT:float; STRING:std::string; NODE:abstract_astnode*; VEC:std::vector<ExpAst*> ; STMT:StmtAst*; EXP:ExpAst*; REF:RefAst*;
%token IF ELSE WHILE FOR IDENTIFIER INT_CONSTANT FLOAT_CONSTANT STRING_LITERAL INC_OP LE_OP GE_OP EQ_OP NE_OP AND_OP OR_OP RETURN VOID INT FLOAT OTHERS PTR_OP STRUCT 

%type<STRING> declarator
%type<VEC> expression_list
%type<INT> declarator_list
%type<INT> declaration_list
%type<INT> declaration
%type<NODE> translation_unit
%type<NODE> struct_specifier
%type<NODE> function_definition
%type<STRING> type_specifier
%type<STRING> fun_declarator
%type<NODE> parameter_list
%type<NODE> parameter_declaration
%type<STMT> compound_statement
%type<STMT> statement_list
%type<STMT> statement
%type<STMT> assignment_statement
%type<EXP> expression
%type<EXP> logical_or_expression
%type<EXP> logical_and_expression
%type<EXP> equality_expression
%type<EXP> relational_expression
%type<EXP> additive_expression 
%type<EXP> multiplicative_expression
%type<EXP> unary_expression
%type<EXP> postfix_expression
%type<EXP> primary_expression
%type<EXP> unary_operator
%type<STMT> selection_statement
%type<STMT> iteration_statement
%type<STRING> IDENTIFIER
%type<INT> INT_CONSTANT
%type<FLOAT> FLOAT_CONSTANT
%type<STRING> STRING_LITERAL

%type<STRING> VOID
%type<STRING> INT
%type<STRING> FLOAT


%scanner-token-function d_scanner.lex()
%scanner Scanner.h

%%
print:
    translation_unit
    {
      fsym.open ("symtab", std::fstream::in | std::fstream::out | std::fstream::app);
      fsym << "GST\n";
      gst->print();
      fsym.close();
      if(gotError == 0)
      {
        fast.open ("ast", std::fstream::in | std::fstream::out | std::fstream::app);
        for(int i=0;i<astQueue.size();++i)
        {
          astQueue[i]->print();
          fast << "\n\n";
        }
        fast.close();
        
        fast.open ("mips.s", std::fstream::in | std::fstream::out | std::fstream::app);
        fast << ".text\n\n";
        for(int i=0,funCount=0;i<astQueue.size();++i,++funCount)
        {
          while(gst->symbol[funCount]->varType!=FUNCTION&&funCount<gst->symbol.size()){
            funCount++;
          }
          fast << astQueue[i]->funcname << ":\n";
          gst->symbol[funCount]->symtab->pushRegsCallee(fast);
          astQueue[i]->genCode(gst->symbol[funCount]->symtab,gst,fast);
          gst->symbol[funCount]->symtab->popRegsCallee(fast);
          fast << "\n\n";
          
        }
        fast.close();
      }
    }
    ;

translation_unit:
    struct_specifier
    {
    }
    | function_definition 
    {
    }
    | translation_unit function_definition 
    {
    }
    | translation_unit struct_specifier
    {
    }
    ;

struct_specifier:
    STRUCT IDENTIFIER '{' 
    {
      gst->addSymbol(new Symbol($2, 2, 2, new Type("",4), st, 4, 0),d_scanner.lineNr(),gotError);
      lOffset = 0;
      inStruct = 1;
    }
    declaration_list '}' ';'
    {
        Symbol* temp = gst->isPresent($2,2);
        temp->type->size = $5;
        temp->size = $5;
        
        inStruct = 0;
        lOffset = 8;
        st = new SymbolTable();
    }
    ;

function_definition:
    type_specifier fun_declarator
    {
      typeStack.top()->update();
      gst->addSymbol(new Symbol($2, 1, 2, typeStack.top(), st, typeStack.top()->size, 0),d_scanner.lineNr(),gotError);
      typeStack.pop();
      lOffset = 0;
    }
    compound_statement
    { 
      lOffset = 8;
      st = new SymbolTable();
      $4->funcname = $2;
      astQueue.push_back($4);
    }
    ;

type_specifier:
    VOID
    {
      type = new Type($1,4);
      typeStack.push(type);
    }
    | INT
    {
      type = new Type($1,4);
      typeStack.push(type);
    }   
    | FLOAT
    {
      type = new Type($1,4);
      typeStack.push(type);
    } 
    | STRUCT IDENTIFIER
    {
      Type* t = gst->checkScope($2,2,d_scanner.lineNr());
      if(t != NULL)
      {
        type = new Type($2,t->size);
        typeStack.push(type);
      }
      else{
        type = new Type("~err",4);
        typeStack.push(type);
      }
    }
    ;

fun_declarator:
    IDENTIFIER '(' parameter_list ')' 
    {
      $$ = $1;
    }
    | IDENTIFIER '(' ')'
    {
      $$ = $1;
    }
    | '*' fun_declarator  //The * is associated with the function name
    {
      $$ = $2;
      type = typeStack.top();
      type->starCount++;
    }
    ;

parameter_list:
    parameter_declaration 
    {
    }
    | parameter_list ',' parameter_declaration 
    {
    }
    ;

parameter_declaration:
    type_specifier declarator
    {
      typeStack.top()->update();
      if(typeStack.top()->array.size() > 0)
      {
        typeStack.top()->size = 4;
      }
      st->addSymbol(new Symbol($2, 0, 0, typeStack.top(), NULL, typeStack.top()->size, lOffset),d_scanner.lineNr(),gotError);
      lOffset += typeStack.top()->size;
      typeStack.pop();
    }
    ;

declarator:
    IDENTIFIER
    {
      $$ = $1;
    }
    | declarator '[' primary_expression']' // check separately that it is a constant
    {
      $$ = $1;
      if(indexArray == 1)
      {
        type = typeStack.top();
        type->array.push_back(((IntConst*)$3)->i);
      }
      else
      {
        gotError = 1;
        cout<<"Line " << d_scanner.lineNr() << " ERROR: size of array ‘" << $1 <<"’ has non-integer type\n";
      }
    }
    | '*' declarator 
    {
      $$ = $2;
      type = typeStack.top();
      type->starCount++;
    }
    ;

primary_expression:       // The smallest expressions, need not have a l_value
    IDENTIFIER            // primary expression has IDENTIFIER now
    {
      Type* t;
      Symbol* temp;
      temp=st->isPresent($1,2) ;
      if(temp==NULL){
        t=st->checkScope($1,0,d_scanner.lineNr()) ;
      }
      else{
        t = temp->type;
      }
      if(t==NULL){
        gotError = 1;
      }
      indexArray = 0;
      Identifier* obj = new Identifier($1);
      if(t==NULL){
        obj->t.name = "~err";
        obj->err = true;
      } 
      else obj->t = *t;
      obj->lValue = true;
      $$ = obj;
    }
    | INT_CONSTANT 
    {
      indexArray = 1;
      IntConst* obj = new IntConst($1);
      obj->t.name = "int";
      obj->lValue = false;
      $$ = obj;
    }
    | FLOAT_CONSTANT
    {
      indexArray = 0;
      FloatConst* obj = new FloatConst($1);
      obj->t.name = "float";
      obj->lValue = false;
      $$ = obj;
    }
    | STRING_LITERAL
    {
      indexArray = 0;
      StringConst* obj = new StringConst($1);
      obj->t.name = "char*";
      obj->lValue = false;
      $$ = obj;
    }
    | '(' expression ')'  
    {
      indexArray = 0;
      $$ = $2;
    }  
    ;

compound_statement:
    '{' '}'
    {
      Empty* obj = new Empty();
      $$ = obj;
    } 
    | '{' statement_list '}'
    {
      $$ = $2;
    }
    | '{' declaration_list statement_list '}' 
    {
      $$ = $3;
    }
    ;

statement_list:
    statement 
    {
      Seq* obj = new Seq();
      (obj)->add_node($1);
      $$ = obj;
    }    
    | statement_list statement
    {
      ((Seq*)$1)->add_node($2);
      $$ = $1;
    }  
    ;

statement:
    '{' statement_list '}'  //a solution to the local decl problem
    {
      $$ = $2;
    }
    | selection_statement  
    {
      $$ = $1;
    } 
    | iteration_statement   
    {
      $$ = $1;
    }
    | assignment_statement  
    {
      $$ = $1;
    }
    | RETURN expression ';'
    {
      Return* obj = new Return($2);
      
      Type* tempType = gst->symbol.back()->type;
      if($2->err == 1){
        gotError = 1;
        obj->err = 1;
      }
      else if(tempType->checkTypeParam($2->t)==false){
        gotError = 1;
        cout << "Line " << d_scanner.lineNr() << " ERROR: incompatible types when returning type ‘"<<$2->t.str()<<"' but '"<<tempType->str()<<"' was expected\n";
        obj->err = 1;
      }
      obj->lValue = 0;
      obj->t.name ="int";
      
      $$ = obj;
    } 
    ;

assignment_statement:
    ';'
    {
      Empty* obj = new Empty();
      $$ = obj;
    }
    | expression ';'
    {
      $$ = $1;
    }
    ;

expression:                     //assignment expressions are right associative
    logical_or_expression
    {
      $$ = $1;
    }
    | unary_expression '=' expression         // l_expression has been replaced by unary_expression.
    {
      Assign* obj = new Assign($1,$3);
      
      if($1->err == 1 ||$3->err == 1){
        obj->err = 1;
      }
      else if($1->lValue == false){
        gotError = 1;
        cout << "Line " << d_scanner.lineNr() << " ERROR: lValue required as left operand of assignment\n";
        obj->err=1;      
      }
      else if($1->t.checkTypeAssign($3->t) == false){
        gotError = 1;
        cout << "Line " << d_scanner.lineNr() << " ERROR: incompatible types when assigning to type '"<<$1->t.str()<<"' from type '"<<$3->t.str()<<"'\n";
        obj->err=1;
      }
      obj->lValue = false;
      obj->t = $1->t;
      if($1->t.str().compare("int")==0 && $3->t.str().compare("float")==0)
        obj->s = "int";
      if($1->t.str().compare("float")==0 && $3->t.str().compare("int")==0)
        obj->s = "float";
      $$ = obj;

    }
    ;                                         // This may generate programs that are syntactically incorrect.
                                              // Eliminate them during semantic analysis.

logical_or_expression:
    logical_and_expression
    {
      $$ = $1;
    }
    | logical_or_expression OR_OP logical_and_expression
    {
      Op2* obj = new Op2("Or",$1,$3);
      if($1->err==1 || $3->err == 1){
        obj->err=1;
      }
      else if(!($1->t.isNumeric())&&!($1->t.isPointer()) || !($3->t.isNumeric())&&!($3->t.isPointer())){
        gotError = 1;
        obj->err=1;
        cout<<"Line " << d_scanner.lineNr() << " ERROR: invalid operands to binary || (have ‘"<<$1->t.str()<<"’ and ‘"<<$3->t.str()<<"’)\n";   
      }
      obj->lValue = false;
      obj->t.name = "int";
      $$ = obj;
    }
    ;

logical_and_expression:
    equality_expression
    {
      $$ = $1;
    }
    | logical_and_expression AND_OP equality_expression 
    { 
      Op2* obj = new Op2("And",$1,$3);
      if($1->err==1 || $3->err == 1){
        obj->err=1;
      }
      else if(!($1->t.isNumeric())&&!($1->t.isPointer()) || !($3->t.isNumeric())&&!($3->t.isPointer())){
        gotError = 1;
        obj->err=1;
        cout<<"Line " << d_scanner.lineNr() << " ERROR: invalid operands to binary && (have ‘"<<$1->t.str()<<"’ and ‘"<<$3->t.str()<<"’)\n";   
      }
      obj->lValue = false;
      obj->t.name = "int";
      $$ = obj;
    }
    ;

equality_expression:
    relational_expression 
    {
      $$ = $1;
    }
    | equality_expression EQ_OP relational_expression   
    {
      Op2* obj = new Op2("Eq_op",$1,$3);
      if($1->err==1 || $3->err == 1){
        obj->err=1;
      }
      else if($1->t.isNumeric() && $3->t.isNumeric()){
        if($1->t.name.compare("float")==0 || $3->t.name.compare("float")==0){
          if($1->t.name.compare("int")==0)
            obj->s1 = "TO-FLOAT";
          if($3->t.name.compare("int")==0)
            obj->s2 = "TO-FLOAT";
          obj->op = "EQ_OP-FLOAT";
        }
        else{
          obj->op = "EQ_OP-INT";
        }
      }
      else if($1->t.isPointer() && $3->t.isPointer() && 
              $1->t.checkTypeParam($3->t) && $3->t.checkTypeParam($1->t)){
          //No error 
      }
      else{
        gotError = 1;
        obj->err=1;
        cout<<"Line " << d_scanner.lineNr() << " ERROR: invalid operands to binary == (have ‘"<<$1->t.str()<<"’ and ‘"<<$3->t.str()<<"’)\n";   
      }
      
      obj->lValue = false;
      obj->t.name = "int";
      
      $$ = obj;
    }
    | equality_expression NE_OP relational_expression
        {
      Op2* obj = new Op2("Ne_op",$1,$3);
      if($1->err==1 || $3->err == 1){
        obj->err=1;
      }
      else if($1->t.isNumeric() && $3->t.isNumeric()){
        if($1->t.name.compare("float")==0 || $3->t.name.compare("float")==0){
          if($1->t.name.compare("int")==0)
            obj->s1 = "TO-FLOAT";
          if($3->t.name.compare("int")==0)
            obj->s2 = "TO-FLOAT";
          obj->op = "NE_OP-FLOAT";
        }
        else{
          obj->op = "NE_OP-INT";
        }
      }
      else if($1->t.isPointer() && $3->t.isPointer() && 
              $1->t.checkTypeParam($3->t) && $3->t.checkTypeParam($1->t)){
          //No error 
      }
      else{
        gotError = 1;
        obj->err=1;
        cout<<"Line " << d_scanner.lineNr() << " ERROR: invalid operands to binary != (have ‘"<<$1->t.str()<<"’ and ‘"<<$3->t.str()<<"’)\n";   
      }
      
      obj->lValue = false;
      obj->t.name = "int";
      
      $$ = obj;
    }
    ;
relational_expression:
    additive_expression
    {
      $$ = $1;
    }
    | relational_expression '<' additive_expression 
    {
      Op2* obj = new Op2("Lt_op",$1,$3);
      if($1->err==1 || $3->err == 1){
        obj->err=1;
      }
      else if($1->t.isNumeric() && $3->t.isNumeric()){
        if($1->t.name.compare("float")==0 || $3->t.name.compare("float")==0){
          if($1->t.name.compare("int")==0)
            obj->s1 = "TO-FLOAT";
          if($3->t.name.compare("int")==0)
            obj->s2 = "TO-FLOAT";
          obj->op = "LT_OP-FLOAT";
        }
        else{
          obj->op = "LT_OP-INT";
        }
      }
      else if($1->t.isPointer() && $3->t.isPointer() && 
              $1->t.checkTypeComp($3->t) && $3->t.checkTypeComp($1->t)){
          //No error 
      }
      else{
        gotError = 1;
        obj->err=1;
        cout<<"Line " << d_scanner.lineNr() << " ERROR: invalid operands to binary < (have ‘"<<$1->t.str()<<"’ and ‘"<<$3->t.str()<<"’)\n";   
      }
      
      obj->lValue = false;
      obj->t.name = "int";
      
      $$ = obj;
    }
    | relational_expression '>' additive_expression 
    {
      Op2* obj = new Op2("Gt_op",$1,$3);
      if($1->err==1 || $3->err == 1){
        obj->err=1;
      }
      else if($1->t.isNumeric() && $3->t.isNumeric()){
        if($1->t.name.compare("float")==0 || $3->t.name.compare("float")==0){
          if($1->t.name.compare("int")==0)
            obj->s1 = "TO-FLOAT";
          if($3->t.name.compare("int")==0)
            obj->s2 = "TO-FLOAT";
          obj->op = "GT_OP-FLOAT";
        }
        else{
          obj->op = "GT_OP-INT";
        }
      }
      else if($1->t.isPointer() && $3->t.isPointer() && 
              $1->t.checkTypeComp($3->t) && $3->t.checkTypeComp($1->t)){
          //No error 
      }
      else{
        gotError = 1;
        obj->err=1;
        cout<<"Line " << d_scanner.lineNr() << " ERROR: invalid operands to binary > (have ‘"<<$1->t.str()<<"’ and ‘"<<$3->t.str()<<"’)\n";   
      }
      
      obj->lValue = false;
      obj->t.name = "int";
      
      $$ = obj;
    }
    | relational_expression LE_OP additive_expression 
    {
      Op2* obj = new Op2("Le_op",$1,$3);
      if($1->err==1 || $3->err == 1){
        obj->err=1;
      }
      else if($1->t.isNumeric() && $3->t.isNumeric()){
        if($1->t.name.compare("float")==0 || $3->t.name.compare("float")==0){
          if($1->t.name.compare("int")==0)
            obj->s1 = "TO-FLOAT";
          if($3->t.name.compare("int")==0)
            obj->s2 = "TO-FLOAT";
          obj->op = "LE_OP-FLOAT";
        }
        else{
          obj->op = "LE_OP-INT";
        }
      }
      else if($1->t.isPointer() && $3->t.isPointer() && 
              $1->t.checkTypeComp($3->t) && $3->t.checkTypeComp($1->t)){
          //No error 
      }
      else{
        gotError = 1;
        obj->err=1;
        cout<<"Line " << d_scanner.lineNr() << " ERROR: invalid operands to binary <= (have ‘"<<$1->t.str()<<"’ and ‘"<<$3->t.str()<<"’)\n";   
      }
      
      obj->lValue = false;
      obj->t.name = "int";
      
      $$ = obj;
    }
    | relational_expression GE_OP additive_expression 
    {
      Op2* obj = new Op2("Ge_op",$1,$3);
      if($1->err==1 || $3->err == 1){
        obj->err=1;
      }
      else if($1->t.isNumeric() && $3->t.isNumeric()){
        if($1->t.name.compare("float")==0 || $3->t.name.compare("float")==0){
          if($1->t.name.compare("int")==0)
            obj->s1 = "TO-FLOAT";
          if($3->t.name.compare("int")==0)
            obj->s2 = "TO-FLOAT";
          obj->op = "GE_OP-FLOAT";
        }
        else{
          obj->op = "GE_OP-INT";
        }
      }
      else if($1->t.isPointer() && $3->t.isPointer() && 
              $1->t.checkTypeComp($3->t) && $3->t.checkTypeComp($1->t)){
          //No error 
      }
      else{
        gotError = 1;
        obj->err=1;
        cout<<"Line " << d_scanner.lineNr() << " ERROR: invalid operands to binary >= (have ‘"<<$1->t.str()<<"’ and ‘"<<$3->t.str()<<"’)\n";   
      }
      
      obj->lValue = false;
      obj->t.name = "int";
      
      $$ = obj;
    }
    ;

additive_expression :
    multiplicative_expression
    {
        $$ = $1;
    }
    | additive_expression '+' multiplicative_expression 
    {
      Op2* obj = new Op2("Plus",$1,$3);
      obj->lValue = false;
      if($1->err==1 || $3->err == 1){
        obj->err=1;
      }
      else if(!$1->t.checkPlus($3->t)){
        gotError = 1;
        obj->err=1;
        cout<<"Line " << d_scanner.lineNr() << " ERROR: invalid operands to binary + (have ‘"<<$1->t.str()<<"’ and ‘"<<$3->t.str()<<"’)\n";   
      }
      else if(($1->t.name.compare("float")==0 || $3->t.name.compare("float")==0) && $1->t.isNumeric() && $3->t.isNumeric()){
        if($1->t.name.compare("int")==0)
          obj->s1 = "TO-FLOAT";
        if($3->t.name.compare("int")==0)
          obj->s2 = "TO-FLOAT";
        obj->op = "PLUS-FLOAT";
        obj->t.name = "float";
      }
      else if($1->t.isNumeric() && $3->t.isNumeric()){
        obj->op = "PLUS-INT";
        obj->t.name = "int";
      }
      else{
        if($1->t.isPointer())
          obj->t = $1->t;
        if($3->t.isPointer())
          obj->t = $3->t;
      }
      $$ = obj;
    }
    | additive_expression '-' multiplicative_expression 
    {
      Op2* obj = new Op2("Minus",$1,$3);
      obj->lValue = false;
      if($1->err==1 || $3->err == 1){
        obj->err=1;
      }
      else if(!$1->t.checkMinus($3->t)){
        gotError = 1;
        obj->err=1;
        cout<<"Line " << d_scanner.lineNr() << " ERROR: invalid operands to binary - (have ‘"<<$1->t.str()<<"’ and ‘"<<$3->t.str()<<"’)\n";   
      }
      else if(($1->t.name.compare("float")==0 || $3->t.name.compare("float")==0) && $1->t.isNumeric() && $3->t.isNumeric()){
        if($1->t.name.compare("int")==0)
          obj->s1 = "TO-FLOAT";
        if($3->t.name.compare("int")==0)
          obj->s2 = "TO-FLOAT";
        obj->op = "MINUS-FLOAT";
        obj->t.name = "float";
      }
      else if($1->t.isNumeric() && $3->t.isNumeric()){
        obj->op = "MINUS-INT";
        obj->t.name = "int";
      }
      else{
        if($3->t.isNumeric())
          obj->t = $1->t;
        if($1->t.isPointer() && $3->t.isPointer())
          obj->t.name = "int";
      }
      $$ = obj;
    }
    ;

multiplicative_expression:
    unary_expression
    {
      $$ = $1;
    }
    | multiplicative_expression '*' unary_expression 
    {
      Op2 *obj = new Op2("Mult",$1,$3);
      if($1->err==1 || $3->err == 1){
        obj->err=1;
      }
      else if(!($1->t.isNumeric()) || !($3->t.isNumeric()) ){
        gotError = 1;
        obj->err=1;
        cout<<"Line " << d_scanner.lineNr() << " ERROR: invalid operands to binary * (have ‘"<<$1->t.str()<<"’ and ‘"<<$3->t.str()<<"’)\n";   
      }
      obj->lValue = false;
      if($1->t.name.compare("float")==0 || $3->t.name.compare("float")==0){
        if($1->t.name.compare("int")==0)
          obj->s1 = "TO-FLOAT";
        if($3->t.name.compare("int")==0)
          obj->s2 = "TO-FLOAT";
        obj->op = "MULT-FLOAT";
        obj->t.name = "float";
      }
      else{
        obj->op = "MULT-INT";
        obj->t.name = "int";
      }
      $$ = obj;
    }
    | multiplicative_expression '/' unary_expression
    {
      Op2 *obj = new Op2("Div",$1,$3);
      if($1->err==1 || $3->err == 1){
        obj->err=1;
      }
      else if(!($1->t.isNumeric()) || !($3->t.isNumeric()) ){
        gotError = 1;
        obj->err=1;
        cout<<"Line " << d_scanner.lineNr() << " ERROR: invalid operands to binary / (have ‘"<<$1->t.str()<<"’ and ‘"<<$3->t.str()<<"’)\n";   
      }
      obj->lValue = false;
      if($1->t.name.compare("float")==0 || $3->t.name.compare("float")==0){
        if($1->t.name.compare("int")==0)
          obj->s1 = "TO-FLOAT";
        if($3->t.name.compare("int")==0)
          obj->s2 = "TO-FLOAT";
        obj->op = "DIV-FLOAT";
        obj->t.name = "float";
      }
      else{
        obj->op = "DIV-INT";
        obj->t.name = "int";
      }
      $$ = obj;
    } 
    ;

unary_expression:
    postfix_expression
    {
      $$ = $1;
    }                
    | unary_operator unary_expression   // unary_operator can only be '*' on the LHS of '='
    {
      ((Op1*)$1)->setChild($2);
      
      $1->t = $2->t;
      if($1->err == 0 && $2->err == 0){
        
        if(((Op1*)$1)->op.compare("Deref") == 0){               // *
          $1->lValue = true;
          // Check $2 to be an address
          if($2->t.starCount == 0 && $2->t.pointer == 0 && $2->t.array.size() == 0){
            gotError = 1;
            $1->err = 1;
            cout << "Line " << d_scanner.lineNr() << " ERROR: invalid type argument of unary ‘*’ (have ‘" << $2->t.str() << "’)\n";
          }
          else if($2->t.starCount == 1 && $2->t.name.compare("void") == 0 && $2->t.array.size() == 0 && $2->t.pointer == 0){
            gotError = 1;
            $1->err = 1;
            cout << "Line " << d_scanner.lineNr() << " ERROR: dereferencing ‘void *’ pointer\n";
          }
          else{
            $1->t.deref();
          }
        }
        
        else if(((Op1*)$1)->op.compare("Pointer") == 0){        // &
          $1->lValue = false;
          if($2->lValue == 0){
            gotError = 1;
            $1->err = 1;
            cout << "Line " << d_scanner.lineNr() << " ERROR: lValue required as unary '&' operand\n";
          }
          else{
            $1->t.ref();
          }
        }
        
        else if(((Op1*)$1)->op.compare("Not") == 0){            // !
          $1->lValue = false;
          $1->t.name = "int";
          $1->t.starCount = 0;
          $1->t.array.clear();
          if($2->t.str().compare("void") == 0){
            gotError = 1;
            $1->err = 1;
            cout << "Line " << d_scanner.lineNr() << " ERROR: invalid use of void expression\n";
          }
          else if($2->t.name.compare("int") != 0 && $2->t.name.compare("float") != 0 && $2->t.name.compare("void") != 0){
            gotError = 1;
            $1->err = 1;
            cout << "Line " << d_scanner.lineNr() << " ERROR: wrong type argument to unary exclamation mark\n";
          }
        }
        
        else{                                                   // -
          $1->lValue = false;
          if(($2->t.str()).compare("void") == 0){
            gotError = 1;
            $1->err = 1;
            cout << "Line " << d_scanner.lineNr() << " ERROR: invalid use of void expression\n";
          }
          else if(($2->t.str()).compare("int") != 0 && ($2->t.str()).compare("float") != 0){
            gotError = 1;
            $1->err = 1;
            cout << "Line " << d_scanner.lineNr() << " ERROR: wrong type argument to unary minus\n";
          }
        }
      }
      else{
        $1->err = 1;
      }
      
      $$ = $1;
    }
    ;                                   // you have to enforce this during semantic analysis

postfix_expression:
    primary_expression
    {
      $$ = $1;
    }                
    | IDENTIFIER '(' ')'  // Cannot appear on the LHS of '='. Enforce this.
    {
      Type* temp;
      Symbol* tempSym;
      if($1 != "printf"){
        temp = gst->checkScope($1,1,d_scanner.lineNr());
        tempSym = gst->isPresent($1,1);
      }
      
      Identifier* obj1 = new Identifier($1);
      std::vector<ExpAst*> x;
      Funcall* obj = new Funcall(obj1,x);
      
      vector<ExpAst*> tempVec;
      obj->lValue = false;
      if($1 != "printf"){
        if(temp==NULL){
          gotError = 1;
          obj->err = true;
        }
        else if(st->isPresent($1,0)!=NULL || st->isPresent($1,2)!=NULL){
          gotError = 1;
          obj->err = true;
          cout << "Line " << d_scanner.lineNr() << " ERROR: called object '" << $1 << "' is not a function or function pointer\n";
        }
        else if(checkFunParams(tempVec,tempSym->symtab,d_scanner.lineNr())==false){
          gotError = 1;
          obj->err = true;
        }
        else{
          obj->t = *temp;
        }
      }
      else{
        obj->t = Type("void",4);
      }
      
      $$ = obj;
    }               
    | IDENTIFIER '(' expression_list ')'  // Cannot appear on the LHS of '='. Enforce this.
    {
      Type* temp;
      Symbol* tempSym;
      if($1 != "printf"){
        temp = gst->checkScope($1,1,d_scanner.lineNr());
        tempSym = gst->isPresent($1,1);
      }
      
      Identifier* obj1 = new Identifier($1);
      Funcall* obj = new Funcall(obj1, $3);
      obj->lValue = false;
      if($1 != "printf"){
        if(temp==NULL){
          gotError = 1;
          obj->err = true;
        }
        else if(st->isPresent($1,0)!=NULL || st->isPresent($1,2)!=NULL){
          gotError = 1;
          obj->err = true;
          cout << "Line " << d_scanner.lineNr() << " ERROR: called object '" << $1 << "' is not a function or function pointer\n";
        }
        else if(checkFunParams($3,tempSym->symtab,d_scanner.lineNr())==false){
          gotError = 1;
          obj->err = true;
        }
        else{
          obj->t = *temp;
        }
      }
      else{
        obj->t = Type("void",4);
      }
        
      $$ = obj;
    } 
    | postfix_expression '[' expression ']'
    {
      ArrayRef* obj = new ArrayRef($1,$3);
      
      obj->t = $1->t;
      obj->lValue = 1;
      if($1->err == 0 && $3->err == 0){
        if($3->t.str().compare("int") != 0){
          gotError = 1;
          obj->err = 1;
          cout << "Line " << d_scanner.lineNr() << " ERROR: array subscript is not an integer\n";
        }
        else if($1->t.starCount == 0 && $1->t.pointer == 0 && $1->t.array.size() == 0){
          gotError = 1;
          obj->err = 1;
          cout << "Line " << d_scanner.lineNr() << " ERROR: subscripted value is neither array nor pointer\n";
        }
        else if($1->t.starCount == 1 && $1->t.name.compare("void") == 0 && $1->t.array.size() == 0 && $1->t.pointer == 0){
          gotError = 1;
          obj->err = 1;
          cout << "Line " << d_scanner.lineNr() << " ERROR: dereferencing ‘void *’ pointer\n";
        }
        else{
          obj->t.deref();
        }
      }
      else{
        obj->err = 1;
      }
      $$ = obj;
    }
    | postfix_expression '.' IDENTIFIER
    {
      
      Identifier* obj1 = new Identifier($3);
      Member *obj = new Member($1,obj1);
      
      obj->lValue = true;
      if($1->err == 0){
        Type* temp = gst->checkMember($1->t.name,$3,d_scanner.lineNr());
        if(temp == NULL){
          gotError = 1;
          obj->err = 1;
        }
        else{
          obj->t = *temp;
        }
      }
      else{
        obj->err = 1;
      }
      
      $$ = obj; 
    }
    | postfix_expression PTR_OP IDENTIFIER 
    {
      
      Identifier* obj1 = new Identifier($3);
      Arrow *obj = new Arrow($1,obj1);
      
      obj->lValue = true;
      if($1->err == 0){
        Type* temp = gst->checkMember($1->t.name,$3,d_scanner.lineNr());
        if(temp == NULL){
          gotError = 1;
          obj->err = 1;
        }
        else{
          obj->t = *temp;
        }
      }
      else{
        obj->err = 1;
      }
      $$ = obj; 
    }
    | postfix_expression INC_OP   // Cannot appear on the LHS of '='. Enforce this.
    {
      Op1* obj = new Op1("Pp",$1);
      
      obj->lValue = false;
      if($1->err == 0){
        if($1->lValue == 0 || $1->t.array.size()>0){
          gotError = 1;
          obj->err = 1;
          cout << "Line " << d_scanner.lineNr() << " ERROR: lValue required as increment operand\n";
        }
        else if($1->t.name.compare("int") != 0 && $1->t.name.compare("float") != 0 && $1->t.name.compare("void") != 0){
          gotError = 1;
          obj->err = 1;
          cout << "Line " << d_scanner.lineNr() << " ERROR: wrong type argument to increment\n";
        }
      }
      else{
        obj->err = 1;
      }
      obj->t = $1->t;
      $$ = obj;
    }             
    ;

expression_list:
    expression
    {
      vector<ExpAst*> x;
      x.push_back($1);
      $$ = x;
    }
    | expression_list ',' expression
    {
      ($1).push_back($3);
      $$ = $1;
    }
    ;

unary_operator:
    '-'   
    {
      Op1* obj = new Op1("Uminus");
      $$ = obj;
    }
    | '!'
    {
      Op1* obj = new Op1("Not");
      $$ = obj;
    }
    | '&'
    {
      Op1* obj = new Op1("Pointer");
      $$ = obj;       
    }
    | '*'   
    {
      Op1* obj = new Op1("Deref");
      $$ = obj;
    }
    ;

selection_statement:
    IF '(' expression ')' statement ELSE statement 
    {
      If* obj = new If($3,$5,$7);
      $$ = obj;
    }
    ;

iteration_statement:
    WHILE '(' expression ')' statement 
    {
      While* obj = new While($3,$5);
      $$ = obj;
    }   
    | FOR '(' expression ';' expression ';' expression ')' statement  //modified this production
    {
      For* obj = new For($3,$5,$7,$9);
      $$ = obj;
    }
    ;

declaration_list:
    declaration
    {
      $$ = $1;
    }
    | declaration_list declaration
    {
      $$ = $1 + $2;
    }
    ;

declaration:
    type_specifier declarator_list ';'
    {
      $$ = $2;
      typeStack.pop();
    }
    ;

declarator_list:
    declarator
    {
      tempSize = typeStack.top()->size;
      typeStack.top()->update();
      if(inStruct == 0){
        lOffset -= typeStack.top()->size;
      }
      if(typeStack.top()->name.compare("~err")!=0)
        st->addSymbol(new Symbol($1, 0, 1, typeStack.top(), NULL, typeStack.top()->size, lOffset),d_scanner.lineNr(),gotError);
      if(inStruct == 1){
        lOffset += typeStack.top()->size;
      }
      type = typeStack.top();
      
      Symbol* temp = gst->symbol.back();
      if(temp->varType == 2 && temp->name.compare(type->name) == 0 && type->starCount == 0){
        gotError = 1;
        cout << "Line " << d_scanner.lineNr() << " ERROR: field ‘" << $1 << "’ has incomplete type\n";
      }
      
      $$ = type->size;
      type = new Type(type->name,tempSize);
      typeStack.pop();
      typeStack.push(type);
    }
    | declarator_list ',' declarator 
    {
      tempSize = typeStack.top()->size;
      typeStack.top()->update();
      if(inStruct == 0){
        lOffset -= typeStack.top()->size;
      }
      st->addSymbol(new Symbol($3, 0, 1, typeStack.top(), NULL, typeStack.top()->size, lOffset),d_scanner.lineNr(),gotError);
      if(inStruct == 1){
        lOffset += typeStack.top()->size;
      }
      type = typeStack.top();
      
      Symbol* temp = gst->symbol.back();
      if(temp->varType == 2 && temp->name.compare(type->name) == 0 && type->starCount == 0){
        gotError = 1;
        cout << "Line " << d_scanner.lineNr() << " ERROR: field ‘" << $3 << "’ has incomplete type\n";
      }
      
      $$ = $1 + type->size;
      type = new Type(type->name,tempSize);
      typeStack.pop();
      typeStack.push(type);
    }
    ;

