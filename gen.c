/* gen - actual generation (writing) of flex scanners */

/*  Copyright (c) 1990 The Regents of the University of California. */
/*  All rights reserved. */

/*  This code is derived from software contributed to Berkeley by */
/*  Vern Paxson. */

/*  The United States Government has rights in this work pursuant */
/*  to contract no. DE-AC03-76SF00098 between the United States */
/*  Department of Energy and the University of California. */

/*  This file is part of flex. */

/*  Redistribution and use in source and binary forms, with or without */
/*  modification, are permitted provided that the following conditions */
/*  are met: */

/*  1. Redistributions of source code must retain the above copyright */
/*     notice, this list of conditions and the following disclaimer. */
/*  2. Redistributions in binary form must reproduce the above copyright */
/*     notice, this list of conditions and the following disclaimer in the */
/*     documentation and/or other materials provided with the distribution. */

/*  Neither the name of the University nor the names of its contributors */
/*  may be used to endorse or promote products derived from this software */
/*  without specific prior written permission. */

/*  THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR */
/*  IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED */
/*  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR */
/*  PURPOSE. */

#include "flexdef.h"
#include "tables.h"


/* declare functions that have forward references */

void genecs (void);
void indent_put2s (const char *, const char *);
void indent_puts (const char *);

static int indent_level = 0;	/* each level is 8 spaces */

#define indent_up() (++indent_level)
#define indent_down() (--indent_level)
#define set_indent(indent_val) indent_level = indent_val

/* Indent to the current level. */

void do_indent ()
{
	register int i = indent_level * 8;

	while (i >= 8) {
		outc ('\t');
		i -= 8;
	}

	while (i > 0) {
		outc (' ');
		--i;
	}
}


/** Make the table for possible eol matches.
 *  @return the newly allocated rule_can_match_eol table
 */
static struct yytbl_data *mkeoltbl (void)
{
	int     i;
	flex_int8_t *tdata = 0;
	struct yytbl_data *tbl;

	tbl = (struct yytbl_data *) calloc (1, sizeof (struct yytbl_data));
	yytbl_data_init (tbl, YYTD_ID_RULE_CAN_MATCH_EOL);
	tbl->td_flags = YYTD_DATA8;
	tbl->td_lolen = num_rules + 1;
	tbl->td_data = tdata =
		(flex_int8_t *) calloc (tbl->td_lolen, sizeof (flex_int8_t));

	for (i = 1; i <= num_rules; i++)
		tdata[i] = rule_has_nl[i] ? 1 : 0;

	buf_prints (&yydmap_buf,
		    "\t{YYTD_ID_RULE_CAN_MATCH_EOL, (void**)&yy_rule_can_match_eol, sizeof(%s)},\n",
		    "flex_int32_t");
	return tbl;
}

/* Generate the table for possible eol matches. */
static void geneoltbl ()
{
	int     i;

	outn ("m4_dnl /* Table of booleans, true if rule could match eol. */");
	out ("m4_define([[M4_YY_RULE_CAN_MATCH_EOL_TABLE_32BIT]],1)\n");
	out_dec ("m4_define([[M4_YY_RULE_CAN_MATCH_EOL_TABLE_SIZE]],[[%d]])\n", num_rules + 1);

	if (gentables) {
		outn ("m4_define([[M4_YY_RULE_CAN_MATCH_EOL_TABLE_DATA]],[[0,");
		for (i = 1; i <= num_rules; i++) {
			out_dec ("%d, ", rule_has_nl[i] ? 1 : 0);
			/* format nicely, 20 numbers per line. */
			if ((i % 20) == 19)
				out ("\n    ");
		}
		out ("]]);\n");
	}
}


/** mkctbl - make full speed compressed transition table
 * This is an array of structs; each struct a pair of integers.
 * You should call mkssltbl() immediately after this.
 * Then, I think, mkecstbl(). Arrrg.
 * @return the newly allocated trans table
 */

static struct yytbl_data *mkctbl (void)
{
	register int i;
	struct yytbl_data *tbl = 0;
	flex_int32_t *tdata = 0, curr = 0;
	int     end_of_buffer_action = num_rules + 1;

	buf_prints (&yydmap_buf,
		    "\t{YYTD_ID_TRANSITION, (void**)&yy_transition, sizeof(%s)},\n",
		    ((tblend + numecs + 1) >= INT16_MAX
		     || long_align) ? "flex_int32_t" : "flex_int16_t");

	tbl = (struct yytbl_data *) calloc (1, sizeof (struct yytbl_data));
	yytbl_data_init (tbl, YYTD_ID_TRANSITION);
	tbl->td_flags = YYTD_DATA32 | YYTD_STRUCT;
	tbl->td_hilen = 0;
	tbl->td_lolen = tblend + numecs + 1;	/* number of structs */

	tbl->td_data = tdata =
		(flex_int32_t *) calloc (tbl->td_lolen * 2, sizeof (flex_int32_t));

	/* We want the transition to be represented as the offset to the
	 * next state, not the actual state number, which is what it currently
	 * is.  The offset is base[nxt[i]] - (base of current state)].  That's
	 * just the difference between the starting points of the two involved
	 * states (to - from).
	 *
	 * First, though, we need to find some way to put in our end-of-buffer
	 * flags and states.  We do this by making a state with absolutely no
	 * transitions.  We put it at the end of the table.
	 */

	/* We need to have room in nxt/chk for two more slots: One for the
	 * action and one for the end-of-buffer transition.  We now *assume*
	 * that we're guaranteed the only character we'll try to index this
	 * nxt/chk pair with is EOB, i.e., 0, so we don't have to make sure
	 * there's room for jam entries for other characters.
	 */

	while (tblend + 2 >= current_max_xpairs)
		expand_nxt_chk ();

	while (lastdfa + 1 >= current_max_dfas)
		increase_max_dfas ();

	base[lastdfa + 1] = tblend + 2;
	nxt[tblend + 1] = end_of_buffer_action;
	chk[tblend + 1] = numecs + 1;
	chk[tblend + 2] = 1;	/* anything but EOB */

	/* So that "make test" won't show arb. differences. */
	nxt[tblend + 2] = 0;

	/* Make sure every state has an end-of-buffer transition and an
	 * action #.
	 */
	for (i = 0; i <= lastdfa; ++i) {
		int     anum = dfaacc[i].dfaacc_state;
		int     offset = base[i];

		chk[offset] = EOB_POSITION;
		chk[offset - 1] = ACTION_POSITION;
		nxt[offset - 1] = anum;	/* action number */
	}

	for (i = 0; i <= tblend; ++i) {
		if (chk[i] == EOB_POSITION) {
			tdata[curr++] = 0;
			tdata[curr++] = base[lastdfa + 1] - i;
		}

		else if (chk[i] == ACTION_POSITION) {
			tdata[curr++] = 0;
			tdata[curr++] = nxt[i];
		}

		else if (chk[i] > numecs || chk[i] == 0) {
			tdata[curr++] = 0;
			tdata[curr++] = 0;
		}
		else {		/* verify, transition */

			tdata[curr++] = chk[i];
			tdata[curr++] = base[nxt[i]] - (i - chk[i]);
		}
	}


	/* Here's the final, end-of-buffer state. */
	tdata[curr++] = chk[tblend + 1];
	tdata[curr++] = nxt[tblend + 1];

	tdata[curr++] = chk[tblend + 2];
	tdata[curr++] = nxt[tblend + 2];

	return tbl;
}


/** Make start_state_list table.
 *  @return the newly allocated start_state_list table
 */
static struct yytbl_data *mkssltbl (void)
{
	struct yytbl_data *tbl = 0;
	flex_int32_t *tdata = 0;
	flex_int32_t i;

	tbl = (struct yytbl_data *) calloc (1, sizeof (struct yytbl_data));
	yytbl_data_init (tbl, YYTD_ID_START_STATE_LIST);
	tbl->td_flags = YYTD_DATA32 | YYTD_PTRANS;
	tbl->td_hilen = 0;
	tbl->td_lolen = lastsc * 2 + 1;

	tbl->td_data = tdata =
		(flex_int32_t *) calloc (tbl->td_lolen, sizeof (flex_int32_t));

	for (i = 0; i <= lastsc * 2; ++i)
		tdata[i] = base[i];

	buf_prints (&yydmap_buf,
		    "\t{YYTD_ID_START_STATE_LIST, (void**)&yy_start_state_list, sizeof(%s)},\n",
		    "struct yy_trans_info*");

	return tbl;
}



/* genctbl - generates full speed compressed transition table */

void genctbl ()
{
	register int i;
	int     end_of_buffer_action = num_rules + 1;

	/* Table of verify for transition and offset to next state. */
	/* 32bit flag for struct yy_trans_info is defined in make_tables() */
	out_dec ("m4_define([[M4_YY_TRANSITION_TABLE_SIZE]],[[%d]])\n",
		tblend + numecs + 1);
	if (gentables)
		out ("m4_define([[M4_YY_TRANSITION_TABLE_DATA]],[[\n");

	/* We want the transition to be represented as the offset to the
	 * next state, not the actual state number, which is what it currently
	 * is.  The offset is base[nxt[i]] - (base of current state)].  That's
	 * just the difference between the starting points of the two involved
	 * states (to - from).
	 *
	 * First, though, we need to find some way to put in our end-of-buffer
	 * flags and states.  We do this by making a state with absolutely no
	 * transitions.  We put it at the end of the table.
	 */

	/* We need to have room in nxt/chk for two more slots: One for the
	 * action and one for the end-of-buffer transition.  We now *assume*
	 * that we're guaranteed the only character we'll try to index this
	 * nxt/chk pair with is EOB, i.e., 0, so we don't have to make sure
	 * there's room for jam entries for other characters.
	 */

	while (tblend + 2 >= current_max_xpairs)
		expand_nxt_chk ();

	while (lastdfa + 1 >= current_max_dfas)
		increase_max_dfas ();

	base[lastdfa + 1] = tblend + 2;
	nxt[tblend + 1] = end_of_buffer_action;
	chk[tblend + 1] = numecs + 1;
	chk[tblend + 2] = 1;	/* anything but EOB */

	/* So that "make test" won't show arb. differences. */
	nxt[tblend + 2] = 0;

	/* Make sure every state has an end-of-buffer transition and an
	 * action #.
	 */
	for (i = 0; i <= lastdfa; ++i) {
		int     anum = dfaacc[i].dfaacc_state;
		int     offset = base[i];

		chk[offset] = EOB_POSITION;
		chk[offset - 1] = ACTION_POSITION;
		nxt[offset - 1] = anum;	/* action number */
	}

	for (i = 0; i <= tblend; ++i) {
		if (chk[i] == EOB_POSITION)
			transition_struct_out (0, base[lastdfa + 1] - i);

		else if (chk[i] == ACTION_POSITION)
			transition_struct_out (0, nxt[i]);

		else if (chk[i] > numecs || chk[i] == 0)
			transition_struct_out (0, 0);	/* unused slot */

		else		/* verify, transition */
			transition_struct_out (chk[i],
					       base[nxt[i]] - (i -
							       chk[i]));
	}


	/* Here's the final, end-of-buffer state. */
	transition_struct_out (chk[tblend + 1], nxt[tblend + 1]);
	transition_struct_out (chk[tblend + 2], nxt[tblend + 2]);

	if (gentables)
		dataend();

	/* Table of pointers to start states. */
	out_dec ("m4_define([[M4_YY_START_STATE_LIST_TABLE_SIZE]],[[%d]])\n", lastsc * 2 + 1);

	if (gentables) {
		out ("m4_define([[M4_YY_START_STATE_LIST_TABLE_DATA]],[[");
		for (i = 0; i < lastsc * 2; ++i) out_dec("%d,",base[i]);
		out_dec("%d]])\n",base[lastsc*2]);
	}

	if (useecs)
		genecs ();
}


/* mkecstbl - Make equivalence-class tables.  */

struct yytbl_data *mkecstbl (void)
{
	register int i;
	struct yytbl_data *tbl = 0;
	flex_int32_t *tdata = 0;

	tbl = (struct yytbl_data *) calloc (1, sizeof (struct yytbl_data));
	yytbl_data_init (tbl, YYTD_ID_EC);
	tbl->td_flags |= YYTD_DATA32;
	tbl->td_hilen = 0;
	tbl->td_lolen = csize;

	tbl->td_data = tdata =
		(flex_int32_t *) calloc (tbl->td_lolen, sizeof (flex_int32_t));

	for (i = 1; i < csize; ++i) {
		ecgroup[i] = ABS (ecgroup[i]);
		tdata[i] = ecgroup[i];
	}

	buf_prints (&yydmap_buf,
		    "\t{YYTD_ID_EC, (void**)&yy_ec, sizeof(%s)},\n",
		    "flex_int32_t");

	return tbl;
}

/* Generate equivalence-class tables. */

void genecs ()
{
	register int i, j;
	int     numrows;

	out ("m4_define([[M4_YY_EC_TABLE_32BIT]],1)\n");
	out_dec ("m4_define([[M4_YY_EC_TABLE_SIZE]],[[%d]])\n",csize);
	if (gentables) outn ("m4_define([[M4_YY_EC_TABLE_DATA]],[[0,");

	for (i = 1; i < csize; ++i) {
		ecgroup[i] = ABS (ecgroup[i]);
		mkdata (ecgroup[i]);
	}

	dataend ();

	if (trace) {
		fputs (_("\n\nEquivalence Classes:\n\n"), stderr);

		numrows = csize / 8;

		for (j = 0; j < numrows; ++j) {
			for (i = j; i < csize; i = i + numrows) {
				fprintf (stderr, "%4s = %-2d",
					 readable_form (i), ecgroup[i]);

				putc (' ', stderr);
			}

			putc ('\n', stderr);
		}
	}
}


/* mkftbl - make the full table and return the struct .
 * you should call mkecstbl() after this.
 */

struct yytbl_data *mkftbl (void)
{
	register int i;
	int     end_of_buffer_action = num_rules + 1;
	struct yytbl_data *tbl;
	flex_int32_t *tdata = 0;

	tbl = (struct yytbl_data *) calloc (1, sizeof (struct yytbl_data));
	yytbl_data_init (tbl, YYTD_ID_ACCEPT);
	tbl->td_flags |= YYTD_DATA32;
	tbl->td_hilen = 0;	/* it's a one-dimensional array */
	tbl->td_lolen = lastdfa + 1;

	tbl->td_data = tdata =
		(flex_int32_t *) calloc (tbl->td_lolen, sizeof (flex_int32_t));

	dfaacc[end_of_buffer_state].dfaacc_state = end_of_buffer_action;

	for (i = 1; i <= lastdfa; ++i) {
		register int anum = dfaacc[i].dfaacc_state;

		tdata[i] = anum;

		if (trace && anum)
			fprintf (stderr, _("state # %d accepts: [%d]\n"),
				 i, anum);
	}

	buf_prints (&yydmap_buf,
		    "\t{YYTD_ID_ACCEPT, (void**)&yy_accept, sizeof(%s)},\n",
		    long_align ? "flex_int32_t" : "flex_int16_t");
	return tbl;
}


/* genftbl - generate full transition table */

void genftbl ()
{
	register int i;
	int     end_of_buffer_action = num_rules + 1;

	if (long_align)
		out ("m4_define([[M4_YY_ACCEPT_TABLE_32BIT]],1)\n");
	out_dec ("m4_define([[M4_YY_ACCEPT_TABLE_SIZE]],[[%d]])\n",lastdfa+1);
	if (gentables) outn ("m4_define([[M4_YY_ACCEPT_TABLE_DATA]],[[0,");

	dfaacc[end_of_buffer_state].dfaacc_state = end_of_buffer_action;

	for (i = 1; i <= lastdfa; ++i) {
		register int anum = dfaacc[i].dfaacc_state;

		mkdata (anum);

		if (trace && anum)
			fprintf (stderr, _("state # %d accepts: [%d]\n"),
				 i, anum);
	}

	dataend ();

	if (useecs)
		genecs ();

	/* Don't have to dump the actual full table entries - they were
	 * created on-the-fly.
	 */
}

/* gentabs - generate data statements for the transition tables */

void gentabs (void)
{
	int     i, j, k, *accset, nacc, *acc_array, total_states;
	int     end_of_buffer_action = num_rules + 1;
	struct yytbl_data *yyacc_tbl = 0, *yymeta_tbl = 0, *yybase_tbl = 0,
		*yydef_tbl = 0, *yynxt_tbl = 0, *yychk_tbl = 0, *yyacclist_tbl=0;
	flex_int32_t *yyacc_data = 0, *yybase_data = 0, *yydef_data = 0,
		*yynxt_data = 0, *yychk_data = 0, *yyacclist_data=0;
	flex_int32_t yybase_curr = 0, yyacclist_curr=0,yyacc_curr=0;

	acc_array = allocate_integer_array (current_max_dfas);
	nummt = 0;

	/* The compressed table format jams by entering the "jam state",
	 * losing information about the previous state in the process.
	 * In order to recover the previous state, we effectively need
	 * to keep backing-up information.
	 */
	++num_backing_up;

	if (reject) {
		/* Write out accepting list and pointer list.

		 * First we generate the "yy_acclist" array.  In the process,
		 * we compute the indices that will go into the "yy_accept"
		 * array, and save the indices in the dfaacc array.
		 */
		int     EOB_accepting_list[2];

		/* Set up accepting structures for the End Of Buffer state. */
		EOB_accepting_list[0] = 0;
		EOB_accepting_list[1] = end_of_buffer_action;
		accsiz[end_of_buffer_state] = 1;
		dfaacc[end_of_buffer_state].dfaacc_set =
			EOB_accepting_list;

		if (long_align)
			out ("m4_define([[M4_YY_ACCLIST_TABLE_32BIT]],1)\n");
		out_dec ("m4_define([[M4_YY_ACCLIST_TABLE_SIZE]],[[%d]])\n",MAX(numas,1)+1);
		if (gentables) outn ("m4_define([[M4_YY_ACCLIST_TABLE_DATA]],[[0,");
        
        buf_prints (&yydmap_buf,
                "\t{YYTD_ID_ACCLIST, (void**)&yy_acclist, sizeof(%s)},\n",
                long_align ? "flex_int32_t" : "flex_int16_t");

        yyacclist_tbl = (struct yytbl_data*)calloc(1,sizeof(struct yytbl_data));
        yytbl_data_init (yyacclist_tbl, YYTD_ID_ACCLIST);
        yyacclist_tbl->td_lolen  = MAX(numas,1) + 1;
        yyacclist_tbl->td_data = yyacclist_data = 
            (flex_int32_t *) calloc (yyacclist_tbl->td_lolen, sizeof (flex_int32_t));
        yyacclist_curr = 1;

		j = 1;		/* index into "yy_acclist" array */

		for (i = 1; i <= lastdfa; ++i) {
			acc_array[i] = j;

			if (accsiz[i] != 0) {
				accset = dfaacc[i].dfaacc_set;
				nacc = accsiz[i];

				if (trace)
					fprintf (stderr,
						 _("state # %d accepts: "),
						 i);

				for (k = 1; k <= nacc; ++k) {
					int     accnum = accset[k];

					++j;

					if (variable_trailing_context_rules
					    && !(accnum &
						 YY_TRAILING_HEAD_MASK)
					    && accnum > 0
					    && accnum <= num_rules
					    && rule_type[accnum] ==
					    RULE_VARIABLE) {
						/* Special hack to flag
						 * accepting number as part
						 * of trailing context rule.
						 */
						accnum |= YY_TRAILING_MASK;
					}

					mkdata (accnum);
                    yyacclist_data[yyacclist_curr++] = accnum;

					if (trace) {
						fprintf (stderr, "[%d]",
							 accset[k]);

						if (k < nacc)
							fputs (", ",
							       stderr);
						else
							putc ('\n',
							      stderr);
					}
				}
			}
		}

		/* add accepting number for the "jam" state */
		acc_array[i] = j;

		dataend ();
		outn ("]])\n");
        if (tablesext) {
            yytbl_data_compress (yyacclist_tbl);
            if (yytbl_data_fwrite (&tableswr, yyacclist_tbl) < 0)
                flexerror (_("Could not write yyacclist_tbl"));
            yytbl_data_destroy (yyacclist_tbl);
            yyacclist_tbl = NULL;
        }
	}

	else {
		dfaacc[end_of_buffer_state].dfaacc_state =
			end_of_buffer_action;

		for (i = 1; i <= lastdfa; ++i)
			acc_array[i] = dfaacc[i].dfaacc_state;

		/* add accepting number for jam state */
		acc_array[i] = 0;
	}

	/* Begin generating yy_accept */

	/* Spit out "yy_accept" array.  If we're doing "reject", it'll be
	 * pointers into the "yy_acclist" array.  Otherwise it's actual
	 * accepting numbers.  In either case, we just dump the numbers.
	 */

	/* "lastdfa + 2" is the size of "yy_accept"; includes room for C arrays
	 * beginning at 0 and for "jam" state.
	 */
	k = lastdfa + 2;

	if (reject)
		/* We put a "cap" on the table associating lists of accepting
		 * numbers with state numbers.  This is needed because we tell
		 * where the end of an accepting list is by looking at where
		 * the list for the next state starts.
		 */
		++k;

	if (long_align)
		out ("m4_define([[M4_YY_ACCEPT_TABLE_32BIT]],1)\n");
	out_dec ("m4_define([[M4_YY_ACCEPT_TABLE_SIZE]],[[%d]])\n",k);
	if (gentables) outn ("m4_define([[M4_YY_ACCEPT_TABLE_DATA]],[[0,");

	buf_prints (&yydmap_buf,
		    "\t{YYTD_ID_ACCEPT, (void**)&yy_accept, sizeof(%s)},\n",
		    long_align ? "flex_int32_t" : "flex_int16_t");

	yyacc_tbl =
		(struct yytbl_data *) calloc (1,
					      sizeof (struct yytbl_data));
	yytbl_data_init (yyacc_tbl, YYTD_ID_ACCEPT);
	yyacc_tbl->td_lolen = k;
	yyacc_tbl->td_data = yyacc_data =
		(flex_int32_t *) calloc (yyacc_tbl->td_lolen, sizeof (flex_int32_t));
    yyacc_curr=1;

	for (i = 1; i <= lastdfa; ++i) {
		mkdata (acc_array[i]);
		yyacc_data[yyacc_curr++] = acc_array[i];

		if (!reject && trace && acc_array[i])
			fprintf (stderr, _("state # %d accepts: [%d]\n"),
				 i, acc_array[i]);
	}

	/* Add entry for "jam" state. */
	mkdata (acc_array[i]);
	yyacc_data[yyacc_curr++] = acc_array[i];

	if (reject) {
		/* Add "cap" for the list. */
		mkdata (acc_array[i]);
		yyacc_data[yyacc_curr++] = acc_array[i];
	}

	dataend ();

	if (tablesext) {
		yytbl_data_compress (yyacc_tbl);
		if (yytbl_data_fwrite (&tableswr, yyacc_tbl) < 0)
			flexerror (_("Could not write yyacc_tbl"));
		yytbl_data_destroy (yyacc_tbl);
		yyacc_tbl = NULL;
	}
	/* End generating yy_accept */

	if (useecs) {

		genecs ();
		if (tablesext) {
			struct yytbl_data *tbl;

			tbl = mkecstbl ();
			yytbl_data_compress (tbl);
			if (yytbl_data_fwrite (&tableswr, tbl) < 0)
				flexerror (_("Could not write ecstbl"));
			yytbl_data_destroy (tbl);
			tbl = 0;
		}
	}

	if (usemecs) {
		/* Begin generating yy_meta */
		/* Write out meta-equivalence classes (used to index
		 * templates with).
		 */
		flex_int32_t *yymecs_data = 0;
		yymeta_tbl =
			(struct yytbl_data *) calloc (1,
						      sizeof (struct
							      yytbl_data));
		yytbl_data_init (yymeta_tbl, YYTD_ID_META);
		yymeta_tbl->td_lolen = numecs + 1;
		yymeta_tbl->td_data = yymecs_data =
			(flex_int32_t *) calloc (yymeta_tbl->td_lolen,
					    sizeof (flex_int32_t));

		if (trace)
			fputs (_("\n\nMeta-Equivalence Classes:\n"),
			       stderr);

		out ("m4_define([[M4_YY_META_TABLE_32BIT]],1)\n");
		out_dec ("m4_define([[M4_YY_META_TABLE_SIZE]],[[%d]])\n",numecs+1);
		if (gentables) outn ("m4_define([[M4_YY_META_TABLE_DATA]],[[0,");
		buf_prints (&yydmap_buf,
			    "\t{YYTD_ID_META, (void**)&yy_meta, sizeof(%s)},\n",
			    "flex_int32_t");

		for (i = 1; i <= numecs; ++i) {
			if (trace)
				fprintf (stderr, "%d = %d\n",
					 i, ABS (tecbck[i]));

			mkdata (ABS (tecbck[i]));
			yymecs_data[i] = ABS (tecbck[i]);
		}

		dataend ();
		if (tablesext) {
			yytbl_data_compress (yymeta_tbl);
			if (yytbl_data_fwrite (&tableswr, yymeta_tbl) < 0)
				flexerror (_
					   ("Could not write yymeta_tbl"));
			yytbl_data_destroy (yymeta_tbl);
			yymeta_tbl = NULL;
		}
		/* End generating yy_meta */
	}

	total_states = lastdfa + numtemps;

	/* Begin generating yy_base */
	if (tblend >= INT16_MAX || long_align)
		out ("m4_define([[M4_YY_BASE_TABLE_32BIT]],1)\n");
	out_dec ("m4_define([[M4_YY_BASE_TABLE_SIZE]],[[%d]])\n",total_states + 1);
	if (gentables) outn ("m4_define([[M4_YY_BASE_TABLE_DATA]],[[0,");

	buf_prints (&yydmap_buf,
		    "\t{YYTD_ID_BASE, (void**)&yy_base, sizeof(%s)},\n",
		    (tblend >= INT16_MAX
		     || long_align) ? "flex_int32_t" : "flex_int16_t");
	yybase_tbl =
		(struct yytbl_data *) calloc (1,
					      sizeof (struct yytbl_data));
	yytbl_data_init (yybase_tbl, YYTD_ID_BASE);
	yybase_tbl->td_lolen = total_states + 1;
	yybase_tbl->td_data = yybase_data =
		(flex_int32_t *) calloc (yybase_tbl->td_lolen,
				    sizeof (flex_int32_t));
	yybase_curr = 1;

	for (i = 1; i <= lastdfa; ++i) {
		register int d = def[i];

		if (base[i] == JAMSTATE)
			base[i] = jambase;

		if (d == JAMSTATE)
			def[i] = jamstate;

		else if (d < 0) {
			/* Template reference. */
			++tmpuses;
			def[i] = lastdfa - d + 1;
		}

		mkdata (base[i]);
		yybase_data[yybase_curr++] = base[i];
	}

	/* Generate jam state's base index. */
	mkdata (base[i]);
	yybase_data[yybase_curr++] = base[i];

	for (++i /* skip jam state */ ; i <= total_states; ++i) {
		mkdata (base[i]);
		yybase_data[yybase_curr++] = base[i];
		def[i] = jamstate;
	}

	dataend ();
	if (tablesext) {
		yytbl_data_compress (yybase_tbl);
		if (yytbl_data_fwrite (&tableswr, yybase_tbl) < 0)
			flexerror (_("Could not write yybase_tbl"));
		yytbl_data_destroy (yybase_tbl);
		yybase_tbl = NULL;
	}
	/* End generating yy_base */


	/* Begin generating yy_def */
	if (total_states >= INT16_MAX || long_align)
		out ("m4_define([[M4_YY_DEF_TABLE_32BIT]],1)\n");
	out_dec ("m4_define([[M4_YY_DEF_TABLE_SIZE]],[[%d]])\n",total_states + 1);
	if (gentables) outn ("m4_define([[M4_YY_DEF_TABLE_DATA]],[[0,");

	buf_prints (&yydmap_buf,
		    "\t{YYTD_ID_DEF, (void**)&yy_def, sizeof(%s)},\n",
		    (total_states >= INT16_MAX
		     || long_align) ? "flex_int32_t" : "flex_int16_t");

	yydef_tbl =
		(struct yytbl_data *) calloc (1,
					      sizeof (struct yytbl_data));
	yytbl_data_init (yydef_tbl, YYTD_ID_DEF);
	yydef_tbl->td_lolen = total_states + 1;
	yydef_tbl->td_data = yydef_data =
		(flex_int32_t *) calloc (yydef_tbl->td_lolen, sizeof (flex_int32_t));

	for (i = 1; i <= total_states; ++i) {
		mkdata (def[i]);
		yydef_data[i] = def[i];
	}

	dataend ();
	if (tablesext) {
		yytbl_data_compress (yydef_tbl);
		if (yytbl_data_fwrite (&tableswr, yydef_tbl) < 0)
			flexerror (_("Could not write yydef_tbl"));
		yytbl_data_destroy (yydef_tbl);
		yydef_tbl = NULL;
	}
	/* End generating yy_def */


	/* Begin generating yy_nxt */
	if (total_states >= INT16_MAX || long_align)
		out ("m4_define([[M4_YY_NXT_TABLE_32BIT]],1)\n");
	out_dec ("m4_define([[M4_YY_NXT_TABLE_SIZE]],[[%d]])\n",tblend+1);
	if (gentables) outn ("m4_define([[M4_YY_NXT_TABLE_DATA]],[[0,");

	buf_prints (&yydmap_buf,
		    "\t{YYTD_ID_NXT, (void**)&yy_nxt, sizeof(%s)},\n",
		    (total_states >= INT16_MAX
		     || long_align) ? "flex_int32_t" : "flex_int16_t");

	yynxt_tbl =
		(struct yytbl_data *) calloc (1,
					      sizeof (struct yytbl_data));
	yytbl_data_init (yynxt_tbl, YYTD_ID_NXT);
	yynxt_tbl->td_lolen = tblend + 1;
	yynxt_tbl->td_data = yynxt_data =
		(flex_int32_t *) calloc (yynxt_tbl->td_lolen, sizeof (flex_int32_t));

	for (i = 1; i <= tblend; ++i) {
		/* Note, the order of the following test is important.
		 * If chk[i] is 0, then nxt[i] is undefined.
		 */
		if (chk[i] == 0 || nxt[i] == 0)
			nxt[i] = jamstate;	/* new state is the JAM state */

		mkdata (nxt[i]);
		yynxt_data[i] = nxt[i];
	}

	dataend ();
	if (tablesext) {
		yytbl_data_compress (yynxt_tbl);
		if (yytbl_data_fwrite (&tableswr, yynxt_tbl) < 0)
			flexerror (_("Could not write yynxt_tbl"));
		yytbl_data_destroy (yynxt_tbl);
		yynxt_tbl = NULL;
	}
	/* End generating yy_nxt */

	/* Begin generating yy_chk */
	if (total_states >= INT16_MAX || long_align)
		out ("m4_define([[M4_YY_CHK_TABLE_32BIT]],1)\n");
	out_dec ("m4_define([[M4_YY_CHK_TABLE_SIZE]],[[%d]])\n",tblend+1);
	if (gentables) outn ("m4_define([[M4_YY_CHK_TABLE_DATA]],[[0,");

	buf_prints (&yydmap_buf,
		    "\t{YYTD_ID_CHK, (void**)&yy_chk, sizeof(%s)},\n",
		    (total_states >= INT16_MAX
		     || long_align) ? "flex_int32_t" : "flex_int16_t");

	yychk_tbl =
		(struct yytbl_data *) calloc (1,
					      sizeof (struct yytbl_data));
	yytbl_data_init (yychk_tbl, YYTD_ID_CHK);
	yychk_tbl->td_lolen = tblend + 1;
	yychk_tbl->td_data = yychk_data =
		(flex_int32_t *) calloc (yychk_tbl->td_lolen, sizeof (flex_int32_t));

	for (i = 1; i <= tblend; ++i) {
		if (chk[i] == 0)
			++nummt;

		mkdata (chk[i]);
		yychk_data[i] = chk[i];
	}

	dataend ();
	if (tablesext) {
		yytbl_data_compress (yychk_tbl);
		if (yytbl_data_fwrite (&tableswr, yychk_tbl) < 0)
			flexerror (_("Could not write yychk_tbl"));
		yytbl_data_destroy (yychk_tbl);
		yychk_tbl = NULL;
	}
	/* End generating yy_chk */

	flex_free ((void *) acc_array);
}


/* Write out a formatted string (with a secondary string argument) at the
 * current indentation level, adding a final newline.
 */

void indent_put2s (const char *fmt, const char *arg)
{
	do_indent ();
	out_str (fmt, arg);
	outn ("");
}


/* Write out a string at the current indentation level, adding a final
 * newline.
 */

void indent_puts (const char *str)
{
	do_indent ();
	outn (str);
}


/* make_tables - generate transition tables
 */

void make_tables (void)
{
	register int i;
	struct yytbl_data *yynultrans_tbl;
	char strtmp[32];

	snprintf(strtmp, sizeof(strtmp), "%d", num_rules);
	buf_m4_define( &m4defs_buf, "M4_YY_NUM_RULES", strtmp);

	if (fullspd) {
		/* Need to define the transet type as a size large
		 * enough to hold the biggest offset.
		 */
		if ( (tblend + numecs + 1) >= INT16_MAX || long_align)
			out ("m4_define([[M4_YY_TRANS_INFO_32BIT]],1)\n");

		/* We require that yy_verify and yy_nxt must be of the same size int. */

		/* In cases where its sister yy_verify *is* a "yes, there is
		 * a transition", yy_nxt is the offset (in records) to the
		 * next state.  In most cases where there is no transition,
		 * the value of yy_nxt is irrelevant.  If yy_nxt is the -1th
		 * record of a state, though, then yy_nxt is the action number
		 * for that state.
		 */
	}
	else {
		out ("m4_define([[M4_YY_TRANS_INFO_32BIT]],1)\n");
	}

	if (fullspd) {
		genctbl ();
		if (tablesext) {
			struct yytbl_data *tbl;

			tbl = mkctbl ();
			yytbl_data_compress (tbl);
			if (yytbl_data_fwrite (&tableswr, tbl) < 0)
				flexerror (_("Could not write ftbl"));
			yytbl_data_destroy (tbl);

			tbl = mkssltbl ();
			yytbl_data_compress (tbl);
			if (yytbl_data_fwrite (&tableswr, tbl) < 0)
				flexerror (_("Could not write ssltbl"));
			yytbl_data_destroy (tbl);
			tbl = 0;

			if (useecs) {
				tbl = mkecstbl ();
				yytbl_data_compress (tbl);
				if (yytbl_data_fwrite (&tableswr, tbl) < 0)
					flexerror (_
						   ("Could not write ecstbl"));
				yytbl_data_destroy (tbl);
				tbl = 0;
			}
		}
	}
	else if (fulltbl) {
		genftbl ();
		if (tablesext) {
			struct yytbl_data *tbl;

			tbl = mkftbl ();
			yytbl_data_compress (tbl);
			if (yytbl_data_fwrite (&tableswr, tbl) < 0)
				flexerror (_("Could not write ftbl"));
			yytbl_data_destroy (tbl);
			tbl = 0;

			if (useecs) {
				tbl = mkecstbl ();
				yytbl_data_compress (tbl);
				if (yytbl_data_fwrite (&tableswr, tbl) < 0)
					flexerror (_
						   ("Could not write ecstbl"));
				yytbl_data_destroy (tbl);
				tbl = 0;
			}
		}
	}
	else {
		gentabs ();
	}

	if (do_yylineno) {

		geneoltbl ();

		if (tablesext) {
			struct yytbl_data *tbl;

			tbl = mkeoltbl ();
			yytbl_data_compress (tbl);
			if (yytbl_data_fwrite (&tableswr, tbl) < 0)
				flexerror (_("Could not write eoltbl"));
			yytbl_data_destroy (tbl);
			tbl = 0;
		}
	}

	if (nultrans) {
		flex_int32_t *yynultrans_data = 0;

		/* Begin generating yy_NUL_trans */
		out_dec ("m4_define([[M4_YY_NUL_TRANS_TABLE_SIZE]],[[%d]])\n",lastdfa+1);
		if (gentables) outn ("m4_define([[M4_YY_NUL_TRANS_TABLE_DATA]],[[0,");
		buf_prints (&yydmap_buf,
			    "\t{YYTD_ID_NUL_TRANS, (void**)&yy_NUL_trans, sizeof(%s)},\n",
			    (fullspd) ? "struct yy_trans_info*" :
			    "flex_int32_t");

		yynultrans_tbl =
			(struct yytbl_data *) calloc (1,
						      sizeof (struct
							      yytbl_data));
		yytbl_data_init (yynultrans_tbl, YYTD_ID_NUL_TRANS);
		if (fullspd)
			yynultrans_tbl->td_flags |= YYTD_PTRANS;
		yynultrans_tbl->td_lolen = lastdfa + 1;
		yynultrans_tbl->td_data = yynultrans_data =
			(flex_int32_t *) calloc (yynultrans_tbl->td_lolen,
					    sizeof (flex_int32_t));

		for (i = 1; i <= lastdfa; ++i) {
			if (fullspd) {
				out_dec ("    &yy_transition[%d],\n",
					 base[i]);
				yynultrans_data[i] = base[i];
			}
			else {
				mkdata (nultrans[i]);
				yynultrans_data[i] = nultrans[i];
			}
		}

		dataend ();
		if (tablesext) {
			yytbl_data_compress (yynultrans_tbl);
			if (yytbl_data_fwrite (&tableswr, yynultrans_tbl) <
			    0)
				flexerror (_
					   ("Could not write yynultrans_tbl"));
			yytbl_data_destroy (yynultrans_tbl);
			yynultrans_tbl = NULL;
		}
		/* End generating yy_NUL_trans */
	}

}

void generate_code(void) {
	int i;
	int     did_eof_rule = false;

	/* This is where we begin writing to the file. */

	skelout(); /* M4 DEFINITIONS AND DATA TABLES */

	/* ntod() constructs the DFA states/tables */
	ntod ();

	for (i = 1; i <= num_rules; ++i)
		if (!rule_useful[i] && i != default_rule)
			line_warning (_("rule cannot be matched"),
				      rule_linenum[i]);

	if (spprdflt && !reject && rule_useful[default_rule])
		line_warning (_
			      ("-s option given but default rule can be matched"),
			      rule_linenum[default_rule]);


	/* Generate the C state transition tables from the DFA. */
	outn("/* C state transition tables generated from the DFA. */\n");
	make_tables ();

	if (ddebug) {		/* Spit out table mapping rules to line numbers. */
		if (long_align)
			out ("m4_define([[M4_YY_RULE_LINENUM_TABLE_32BIT]],1)\n");
		out_dec ("m4_define([[M4_YY_RULE_LINENUM_TABLE_SIZE]],[[%d]])\n"
			"m4_define([[M4_YY_RULE_LINENUM_TABLE_DATA]],[[0,\n",num_rules);
		for (i = 1; i < num_rules; ++i)
			mkdata (rule_linenum[i]);
		dataend ();
	}

	/* end M4_GEN_DATA_TABLES */

        /* Dump the stored m4 definitions. */

	buf_print_strings(&m4defs_buf, stdout);
	buf_free(&m4defs_buf);

	/* Write out remaining m4 macros directly */

	if (reject)
		out_m4_define("M4_YY_USES_REJECT", NULL);

	if (real_reject)
		out_m4_define("M4_YY_REAL_REJECT", NULL);

	if (yymore_used)
		out_m4_define("M4_YY_USES_YYMORE", NULL);

	if (!do_yywrap)
		out_m4_define("M4_YY_SKIP_YYWRAP", NULL);

	if (ddebug)
		out_m4_define("M4_FLEX_DEBUG", NULL);

	if (csize == 256)
		out_m4_define("M4_YY_CHAR_TYPE", "unsigned char");
	else
		out_m4_define("M4_YY_CHAR_TYPE", "char");

	if (interactive)
		out_m4_define("M4_YY_INTERACTIVE",NULL);

	if (do_stdinit)
		out_m4_define("M4_YY_DO_STDINIT",NULL);

	if (fullspd)
		out_m4_define("M4_YY_FULLSPD",NULL);

	if (fulltbl)
		out_m4_define("M4_YY_FULLTBL",NULL);

	if (nultrans)
		out_m4_define("M4_YY_NULTRANS",NULL);

	if (!fullspd && !fulltbl)
		out_m4_define("M4_YY_COMPRESSED",NULL);


	if (gentables)
		out_m4_define("M4_YY_GENTABLES",NULL);

	if (lex_compat)
		out_m4_define("M4_YY_FLEX_LEX_COMPAT",NULL);

        fprintf(stdout, "m4_define( [[%s]], [[0x%08x]])m4_dnl\n",
			"M4_YY_TRAILING_MASK",YY_TRAILING_MASK);

        fprintf(stdout, "m4_define( [[%s]], [[0x%08x]])m4_dnl\n",
			"M4_YY_TRAILING_HEAD_MASK",YY_TRAILING_HEAD_MASK);

	if (headerfilename)
		out_m4_define("M4_YY_HEADER_FILENAME",headerfilename);

	if (outfilename)
		out_m4_define("M4_YY_SOURCE_FILENAME",outfilename);

	if (posix_compat)
		out_m4_define("M4_YY_POSIXLY_CORRECT",NULL);

	if (use_read)
		out_m4_define("M4_YY_USE_READ",NULL);

        if (!gen_line_dirs)
		out_m4_define("M4_YY_NO_LINE",NULL);

        if (bol_needed)
		out_m4_define("M4_YY_BOL_NEEDED",NULL);

	if (!reject && num_backing_up > 0)
		out_m4_define("M4_YY_NEED_BACKING_UP",NULL);

	if (variable_trailing_context_rules)
		out_m4_define("M4_YY_VARIABLE_TRAILING_CONTEXT_RULES", NULL);

	if (printstats)
		out_m4_define("M4_YY_VERBOSE",NULL);

	if (nowarn)
		out_m4_define("M4_YY_NOWARN",NULL);

	if (spprdflt)
		out_m4_define("M4_YY_NODEFAULT",NULL);

	if (performance_report > 1) /* a buf_m4_define_int would be nice. */
		out_m4_define("M4_YY_PERFORMANCE_REPORT",NULL);

	if (useecs)
		out_m4_define("M4_YY_ECS",NULL);

	if (usemecs)
		out_m4_define("M4_YY_META_ECS",NULL);

        fprintf(stdout, "m4_define( [[M4_YY_LASTDFA]], [[%d]])\n",lastdfa);

        fprintf(stdout, "m4_define( [[M4_YY_JAMSTATE]], [[%d]])\n",jamstate);

        fprintf(stdout, "m4_define( [[M4_YY_JAMBASE]], [[%d]])\n",jambase);

        fprintf(stdout, "m4_define( [[M4_YY_NUL_EC]], [[%d]])\n",NUL_ec);

	skelout(); /* USER TOP CODE */

	/* Dump the user defined %top{} preproc directives. */
	/* Source #line directives are inserted while scanning. */
	if( top_buf.elts)
		outn((char*) top_buf.elts);

	skelout(); /* USER PREDEFINES */

	/* Dump the command-line -D defines. */
	if (userdef_buf.elts) {
        	if (gen_line_dirs)
			out("#line 1 <command line>\n");
		outn ((char *) (userdef_buf.elts));
	}

	skelout(); /* USER SECTION 1 */

	/* Source #line directive is added while scanning. */
	out (&action_array[defs1_offset]);

	skelout(); /* USER BOTTOM CODE */

	/* Dump the user defined %bottom{} preproc directives. */
	/* Source #line directives are inserted while scanning. */
	if( bottom_buf.elts)
		outn((char*) bottom_buf.elts);

	skelout(); /* USER DECLARATIONS */
	/* User declaration section (prolog) */

	/* Copy prolog to output file. */
	out (&action_array[prolog_offset]);

	skelout(); /* GEN ACTIONS */
	/* Copy actions to output file. */
	indent_up ();
	out (&action_array[action_offset]);

	/* This line directive re-syncs after dumping the action array (FIXME?) */
	line_directive_out (stdout, 0);

	/* generate cases for any missing EOF rules */
	for (i = 1; i <= lastsc; ++i)
		if (!sceof[i]) {
			do_indent ();
			out_str ("case YY_STATE_EOF(%s):\n", scname[i]);
			did_eof_rule = true;
		}

	if (did_eof_rule) {
		indent_up ();
		indent_puts ("yyterminate();");
		indent_down ();
	}

	skelout(); /* USER SECTION 3 */
        /* User code, section 3 */

	/* This line directive re-syncs to the input line number */
	line_directive_out (stdout, 1);
	if (sectnum == 3) (void) flexscan ();	/* copy remainder of input to output */

	skelout(); /* REMAINDER OF SKELETON */
}
