

// There may be some flexer directives here

%%
"//"[^\n]*\n
[ \t\n]                                   								//	return Parser::NEWLINE;//skip
"if"       																	return Parser::IF;
"else"       																return Parser::ELSE;
"while"       																return Parser::WHILE;
"for"       																return Parser::FOR;
"struct"       																return Parser::STRUCT;
(([1-9][0-9]*)|(0[bB][01]*)|(0[0-7]*)|(0[xX][0-9a-fA-F]*))       			{Parser::d_val__ = std::stoi((std::string (matched())),NULL,10);return ParserBase::INT_CONSTANT;}
("."[0-9]+([eE]([-+]?)[0-9]+)?)|([0-9]+"."[0-9]*([eE]([-+]?)[0-9]+)?)   	{std::string::size_type sz;Parser::d_val__ = std::stof((std::string (matched())),&sz);return ParserBase::FLOAT_CONSTANT;}
"\""[^\n"\\]*(\\[nt"\\][^\n"\\]*)*"\""										{Parser::d_val__ = std::string (matched());return ParserBase::STRING_LITERAL;}
"++"       																	return Parser::INC_OP;
"<="       																	return Parser::LE_OP;
">="       																	return Parser::GE_OP;
"=="       																	return Parser::EQ_OP;
"!="       																	return Parser::NE_OP;
"&&"       																	return Parser::AND_OP;
"||"       																	return Parser::OR_OP;
"->"       																	return Parser::PTR_OP;
"return"       																return Parser::	RETURN;
"void"       																{Parser::d_val__ = std::string (matched());return ParserBase::VOID;}
"int"       																{Parser::d_val__ = std::string (matched());return ParserBase::INT;}
"float"       																{Parser::d_val__ = std::string (matched());return ParserBase::FLOAT;}
([[:alpha:]_])([[:alnum:]_])*       										{Parser::d_val__ = std::string (matched());return ParserBase::IDENTIFIER;}
"("       																	return '(';
")"       																	return ')';
","       																	return ',';
"["       																	return '[';
"]"       																	return ']';
"{"       																	return '{';
"}"       																	return '}';
"!"       																	return '!';
"-"       																	return '-';
"+"       																	return '+';
";"       																	return ';';
"*"       																	return '*';
"&"       																	return '&';
"/"       																	return '/';
"="       																	return '=';
"<"       																	return '<';
">"       																	return '>';
"."       																	return '.';
.         																	return Parser::OTHERS;
