/*
 *   tables_shared.c - tables serialization code
 * 
 *   Copyright (c) 1990 The Regents of the University of California.
 *   All rights reserved.
 * 
 *   This code is derived from software contributed to Berkeley by
 *   Vern Paxson.
 * 
 *   The United States Government has rights in this work pursuant
 *   to contract no. DE-AC03-76SF00098 between the United States
 *   Department of Energy and the University of California.
 * 
 *   This file is part of flex.
 * 
 *   Redistribution and use in source and binary forms, with or without
 *   modification, are permitted provided that the following conditions
 *   are met:
 * 
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 * 
 *   Neither the name of the University nor the names of its contributors
 *   may be used to endorse or promote products derived from this software
 *   without specific prior written permission.
 * 
 *   THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 *   IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 *   WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *   PURPOSE.
 * 
*/

/* This file is meant to be included in both the skeleton and the actual
 * flex code (hence the name "_shared").
 * Currently, the source code is copied directly instead of including this file.
 */
#include "flexdef.h"
#include "tables.h"

/** Get the number of integers in this table. This is NOT the
 *  same thing as the number of elements.
 *  @param td the table 
 *  @return the number of integers in the table
 */
flex_int32_t yytbl_calc_total_len (const struct yytbl_data *tbl)
{
	flex_int32_t n;

	/* total number of ints */
	n = tbl->td_lolen;
	if (tbl->td_hilen > 0)
		n *= tbl->td_hilen;

	if (tbl->td_id == YYTD_ID_TRANSITION)
		n *= 2;
	return n;
}
