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
/* Build "scanner.c". 
   The scanner is not important. 
   This tests the use of %header{ ... %} as an alternative to %top{ ... }.
   %top is easy to break with brace characters, like the one in the string below.
*/
#include <stdio.h>
#include <stdlib.h>
#include "config.h"

#ifndef DEFINE_ME
#error "DEFINE_ME undefined!"
#endif
%}

%header{
#define DEFINE_ME "hello{"
%}

%option reentrant
%option 8bit outfile="scanner.c" prefix="test"
%option nounput nomain noyywrap 
%option warn


%%

.|\n              { }

%%

