/*
 * This file is part of flex.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 
 * Neither the name of the University nor the names of its contributors
 * may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE.
 */

%{
/* A template scanner file to build "scanner.c". */
#include <stdio.h>
#include <stdlib.h>
#include "config.h"
%}

%option 8bit
%option nounput nomain noyywrap 
%option warn yylineno c++



%%

foo|bar         ;
[[:digit:]]+    ;
[[:blank:]]+    ;
.|\n            ;
%%

#include <fstream>
int main ( int argc, char** argv )
{
    std::ifstream* fp;
    yyFlexLexer *lexer;

#ifdef TEST_HAS_TABLES_EXTERNAL
    fp = new std::ifstream(argv[1],std::ios::binary);
    if(!fp->is_open())
        YY_GLOBAL_FATAL_ERROR("could not open tables file for reading");

    if(yyFlexLexer::yytables_fload(fp) < 0)
        YY_GLOBAL_FATAL_ERROR("yytables_fload returned < 0");

    delete fp;
#ifdef TEST_HAS_TABLES_VERIFY
    exit(0);
#endif
#endif
    
    if(argc > 2){
	fp = new std::ifstream(argv[2]);
	if (!fp->is_open())
            YY_GLOBAL_FATAL_ERROR("could not open input file for reading");
        lexer = new yyFlexLexer(fp);
    } else {
        lexer = new yyFlexLexer(&std::cin);
    }

    while(lexer->lex() != 0)
        ;
        
#ifdef TEST_HAS_TABLES_EXTERNAL
    lexer->tables_destroy();
#endif
    delete lexer;

    return 0;
}
