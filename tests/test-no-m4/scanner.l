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
/* If any of these #defines get parsed by m4, the trailing quote will
 * lost, causing a compile error.
 */

%top{
#define TEST_TOP "m4_dnl"
}

%header{
#define TEST_HEADER "m4_dnl"
%}

%{
/* A template scanner file to build "scanner.c". */
#include <stdio.h>
#include <stdlib.h>
#include "config.h"
/*#include "parser.h" */
#define TEST1 "m4_dnl"
%}

%option 8bit outfile="scanner.c" prefix="test"
%option nounput nomain noyywrap 
%option warn


%%
%{
#define TEST2 "m4_dnl"
%}
.              { }

%%

#define TEST3 "m4_dnl"

int main(void);
const char *string = TEST_TOP TEST_HEADER TEST1 TEST2 TEST3;
int
main ()
{
    yyin = stdin;
    yyout = stdout;
    yylex();
    puts(string);
    puts("TEST RETURNING OK.");
    return 0;
}
