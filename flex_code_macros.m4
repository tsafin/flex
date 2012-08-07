#===================================================================
m4_dnl /* Generate the code to find the next compressed-table state. */
m4_define([[M4_GEN_NEXT_COMPRESSED_STATE]],
[[
	register YY_CHAR yy_c = $1;

m4_dnl	/* Save the backing-up info \before/ computing the next state
m4_dnl	 * because we always compute one more state than needed - we
m4_dnl	 * always proceed until we reach a jam state
m4_dnl	 */
M4_GEN_BACKING_UP()

	while ( yy_chk[yy_base[yy_current_state] + yy_c] != yy_current_state )
	{
		yy_current_state = (int) yy_def[yy_current_state];
    m4_ifdef([[M4_YY_META_ECS]],
    [[
m4_dnl		/* Templates are arranged so that they never chain
m4_dnl		 * to one another.  This means we can afford to make a
m4_dnl		 * very simple test to see if we need to convert to
m4_dnl		 * yy_c's meta-equivalence class without worrying
m4_dnl		 * about erroneously looking up the meta-equivalence
m4_dnl		 * class twice
m4_dnl		 */
m4_dnl		/* lastdfa + 2 is the beginning of the templates */
		if ( yy_current_state >= (YY_LASTDFA+2) )
			yy_c = yy_meta[(unsigned int) yy_c];
    ]])
	}
	yy_current_state = yy_nxt[yy_base[yy_current_state] + (unsigned int) yy_c];
]])
#===================================================================
m4_dnl /* Generate the code to find the start state. */
m4_define([[M4_GEN_START_STATE]],
[[
    m4_ifdef( [[M4_YY_FULLSPD]],
    [[
	m4_ifdef( [[M4_YY_BOL_NEEDED]],
	[[
		yy_current_state = yy_start_state_list[yy_start + YY_AT_BOL()];
	]],
	[[
		yy_current_state = yy_start_state_list[yy_start];
	]])
    ]],
    [[
		yy_current_state = yy_start;
	m4_ifdef( [[M4_YY_BOL_NEEDED]],
	[[
		yy_current_state += YY_AT_BOL();
	]])
	m4_ifdef( [[M4_YY_USES_REJECT]],[[m4_dnl /* Set up for storing up states. */
		yy_state_ptr = yy_state_buf;
		*yy_state_ptr++ = yy_current_state;
	]])
    ]])
]])
#===================================================================
m4_ifdef([[M4_YY_NEED_BACKING_UP]],
[[
    m4_define([[M4_GEN_BACKING_UP]],
    [[
	m4_ifdef( [[M4_YY_FULLSPD]],
	[[
	if ( yy_current_state[-1].yy_nxt )
	]],
	[[
	if ( yy_accept[yy_current_state] )
	]])
	{
		yy_last_accepting_state = yy_current_state;
		yy_last_accepting_cpos = yy_cp;
	}
    ]])
]],
[[
    m4_define([[M4_GEN_BACKING_UP]],[[]])
]])
#===================================================================
# Generate the code to find the next match.
# NOTE - changes in here should be reflected in gen_next_state() and
# gen_NUL_trans().
m4_ifdef([[M4_YY_ECS]],
[[
    m4_define([[M4_CHARMAP1]],[[yy_ec[YY_SC_TO_UI(*yy_cp)] ]])
    m4_define([[M4_CHARMAP2]],[[yy_ec[YY_SC_TO_UI(*(++yy_cp))] ]])
]],
[[
    m4_define([[M4_CHARMAP1]],[[YY_SC_TO_UI(*yy_cp)]])
    m4_define([[M4_CHARMAP2]],[[YY_SC_TO_UI(*(++yy_cp))]])
]])
#===================================================================
m4_define([[M4_GEN_NEXT_MATCH]],
[[
    m4_ifdef( [[M4_YY_FULLTBL]],
[[
	while ( (yy_current_state = yy_nxt[yy_current_state*YY_NXT_LOLEN + ]]M4_CHARMAP1[[ ]) > 0 )
	{
M4_GEN_BACKING_UP()
		++yy_cp;
	}
	yy_current_state = -yy_current_state;
    ]],
    [[
	m4_ifdef([[M4_YY_FULLSPD]],
	[[
	{
		register const struct yy_trans_info *yy_trans_info;
		register YY_CHAR yy_c;
		for ( yy_c = M4_CHARMAP1;
		      (yy_trans_info = &yy_current_state[(unsigned int) yy_c])->yy_verify == yy_c;
		      yy_c = M4_CHARMAP2)
		{
M4_GEN_BACKING_UP()
			yy_current_state += yy_trans_info->yy_nxt;
		}
	}
	]],[[ m4_dnl else COMPRESSED
	do {
M4_GEN_NEXT_STATE(0)
		++yy_cp;
	}
	    m4_ifdef([[M4_YY_INTERACTIVE]],
	    [[
		while ( yy_base[yy_current_state] != YY_JAMBASE );
	    ]],
	    [[
		while ( yy_current_state != YY_JAMSTATE );
		m4_ifdef([[M4_YY_USES_REJECT]],,
		[[
/* Do the guaranteed-needed backing up to figure out the match. */
		yy_cp = yy_last_accepting_cpos;
		yy_current_state = yy_last_accepting_state;
		]])
	    ]])
	]])
    ]])
]])
#===================================================================
m4_dnl /* Generate the code to find the action number. */
m4_define([[M4_GEN_FIND_ACTION_NUMBER]],
[[
    m4_if_elseif([[M4_YY_FULLSPD]],
    [[
		yy_act = yy_current_state[-1].yy_nxt;
    ]],
    [[M4_YY_FULLTBL]],
    [[
		yy_act = yy_accept[yy_current_state];
    ]],
    [[M4_YY_USES_REJECT]],
    [[
		yy_current_state = *--yy_state_ptr;
		yy_lp = yy_accept[yy_current_state];

find_rule: /* we branch to this label when backing up */

		for ( ; ; ) /* until we find what rule we matched */
		{

			if ( yy_lp && yy_lp < yy_accept[yy_current_state + 1] )
			{
				yy_act = yy_acclist[yy_lp];

	m4_ifdef( [[M4_YY_VARIABLE_TRAILING_CONTEXT_RULES]],
	[[
				if ( yy_act & YY_TRAILING_HEAD_MASK ||
					yy_looking_for_trail_begin )
				{
					if ( yy_act == yy_looking_for_trail_begin )
					{
						yy_looking_for_trail_begin = 0;
						yy_act &= ~YY_TRAILING_HEAD_MASK;
						break;
					}
				}
				else if ( yy_act & YY_TRAILING_MASK )
				{
					yy_looking_for_trail_begin = yy_act & ~YY_TRAILING_MASK;
					yy_looking_for_trail_begin |= YY_TRAILING_HEAD_MASK;

	    m4_ifdef([[M4_YY_REAL_REJECT]],
	    [[
		/* Remember matched text in case we back up
		 * due to REJECT.
		 */
					yy_full_match = yy_cp;
					yy_full_state = yy_state_ptr;
					yy_full_lp = yy_lp;
	    ]])
				}
				else
				{
					yy_full_match = yy_cp;
					yy_full_state = yy_state_ptr;
					yy_full_lp = yy_lp;
					break;
				}

				++yy_lp;
				goto find_rule;

			}
	]],
	[[
		/* Remember matched text in case we back up due to
		 * trailing context plus REJECT.
		 */
			{
				yy_full_match = yy_cp;
				break;
			}
	]])

		}
		--yy_cp;

	/* We could consolidate the following two lines with those at
	 * the beginning, but at the cost of complaints that we're
	 * branching inside a loop.
	 */
		yy_current_state = *--yy_state_ptr;
		yy_lp = yy_accept[yy_current_state];
	}
    ]],
    [[m4_dnl else compressed, no reject
		yy_act = yy_accept[yy_current_state];
	m4_ifdef([[M4_YY_INTERACTIVE]],
	[[
m4_dnl		/* Do the guaranteed-needed backing up to figure out
m4_dnl		 * the match.
m4_dnl		 */
		if ( yy_act == 0 )
		{ /* have to back up */
			yy_cp = yy_last_accepting_cpos;
			yy_current_state = yy_last_accepting_state;
			yy_act = yy_accept[yy_current_state];
		}
	]])
    ]])
]])

#===================================================================
m4_dnl /* Generate the code to find the next state. */
m4_dnl /* NOTE - changes in here should be reflected in gen_next_match() */
# M4_GEN_NEXT_STATE(bool worry_about_NULs)
# ----------------------------------------
m4_define([[M4_GEN_NEXT_STATE]],
[[
    m4_if(($1 && !m4_defined([[M4_YY_NULTRANS]])),
    [[
	m4_ifdef([[M4_YY_ECS]],
	[[
	    m4_define([[M4_CHARMAP]],[[(*yy_cp ? yy_ec[YY_SC_TO_UI(*yy_cp)] : YY_NUL_EC)]])
	]],
	[[
	    m4_define([[M4_CHARMAP]],[[(*yy_cp ? YY_SC_TO_UI(*yy_cp) : YY_NUL_EC)]])
	]])
    ]],
    [[
	m4_ifdef([[M4_YY_ECS]],
	[[
	    m4_define([[M4_CHARMAP]],[[yy_ec[YY_SC_TO_UI(*yy_cp)] ]])
	]],
	[[
	    m4_define([[M4_CHARMAP]],[[YY_SC_TO_UI(*yy_cp)]])
	]])
    ]])
    m4_if(($1 && m4_defined([[M4_YY_NULTRANS]])),
    [[
	m4_ifdef([[M4_YY_COMPRESSED]],
	[[
m4_dnl		/* Compressed tables back up *before* they match. */
M4_GEN_BACKING_UP()
	]])
	if ( *yy_cp )
	{
    ]])
    m4_ifdef([[M4_YY_FULLTBL]],
    [[
	yy_current_state = yy_nxt[yy_current_state*YY_NXT_LOLEN + M4_CHARMAP];
    ]],
    [[
	m4_ifdef([[M4_YY_FULLSPD]],
	[[
		yy_current_state += yy_current_state[M4_CHARMAP].yy_nxt;
	]],
	[[
M4_GEN_NEXT_COMPRESSED_STATE(M4_CHARMAP)
	]])
    ]])
    m4_if(($1 && m4_defined([[M4_YY_NULTRANS]])),
    [[
	}
	else
		yy_current_state = yy_nul_trans[yy_current_state];
    ]])
    m4_ifdef([[M4_YY_COMPRESSED]],,
    [[
M4_GEN_BACKING_UP()
    ]])
    m4_ifdef([[M4_YY_USES_REJECT]],
[[
		*yy_state_ptr++ = yy_current_state;
    ]])
]])

#===================================================================
m4_dnl /* Generate the code to make a NUL transition. */
m4_dnl /* NOTE - changes in here should be reflected in gen_next_match()
m4_dnl  * Only generate a definition for "yy_cp" if we'll generate code
m4_dnl  * that uses it.  Otherwise lint and the like complain.
m4_dnl  */
m4_define([[M4_GEN_NUL_TRANSITION]],
[[
    m4_if((m4_defined([[M4_YY_NEED_BACKING_UP]]) && (!m4_defined([[M4_YY_NULTRANS]]) ||
	    m4_defined([[M4_YY_FULLSPD]]) || m4_defined([[M4_YY_FULLTBL]]))),
    [[
m4_dnl /* We're going to need yy_cp lying around for the call
m4_dnl  * below to gen_backing_up().
m4_dnl  */
	register char *yy_cp = yy_c_buf_p;
    ]])

    m4_if_elseif([[M4_YY_NULTRANS]],
    [[
	yy_current_state = yy_nul_trans[yy_current_state];
	yy_is_jam = (yy_current_state == 0);
    ]],[[M4_YY_FULLTBL]],
    [[
	yy_current_state = yy_nxt[yy_current_state*YY_NXT_LOLEN + YY_NUL_EC];
	yy_is_jam = (yy_current_state <= 0);
    ]],[[M4_YY_FULLSPD]],
    [[
	register int yy_c = YY_NUL_EC;
	register const struct yy_trans_info *yy_trans_info;
	yy_trans_info = &yy_current_state[(unsigned int) yy_c];
	yy_current_state += yy_trans_info->yy_nxt;
	yy_is_jam = (yy_trans_info->yy_verify != yy_c);
    ]],
    [[
M4_GEN_NEXT_COMPRESSED_STATE([[YY_NUL_EC]])
	yy_is_jam = (yy_current_state == YY_JAMSTATE);
	m4_ifdef([[M4_YY_REJECT]],
	[[
m4_dnl /* Only stack this state if it's a transition we
m4_dnl * actually make.  If we stack it on a jam, then
m4_dnl * the state stack and yy_c_buf_p get out of sync.
m4_dnl */
	if ( ! yy_is_jam )
		*yy_state_ptr++ = yy_current_state;
	]])
    ]])
m4_dnl /* If we've entered an accepting state, back up; note that
m4_dnl * compressed tables have *already* done such backing up, so
m4_dnl * we needn't bother with it again.
m4_dnl */
    m4_if((m4_defined([[M4_YY_NEED_BACKING_UP]]) && !m4_defined([[M4_YY_COMPRESSED]])),
    [[
	if ( ! yy_is_jam )
	{
M4_GEN_BACKING_UP()
	}
    ]])
]])

m4_dnl Define the default C code for YY_INPUT:
m4_ifdef( [[M4_YY_USE_READ]],
[[
    m4_define([[M4_YY_INPUT]],
    [[
	errno=0; 
	while ( (result = read( fileno(yyin), (char *) buf, max_size )) < 0 )
		{
		if ( errno != EINTR)
			{
			YY_FATAL_ERROR("input in flex scanner failed");
			break;
			}
		errno=0;
		clearerr(yyin);
		}
    ]])
]],
[[
    m4_define([[M4_YY_INPUT]],
    [[
	if ( YY_CURRENT_BUFFER->is_interactive )
		{
		int c = '*';
		int n;
		for( n = 0; n < (int)max_size &&
			     (c = getc( yyin )) != EOF && c != '\n'; ++n )
			buf[n] = (char) c;
		if ( c == '\n' )
			buf[n++] = (char) c;
		if ( c == EOF && ferror( yyin ) )
			YY_FATAL_ERROR("input in flex scanner failed");
		result = n;
		}
	else
		{
		errno=0;
		while ( (result = fread(buf, 1, max_size, yyin))==0 && ferror(yyin))
			{
			if ( errno != EINTR)
				{
				YY_FATAL_ERROR("input in flex scanner failed");
				break;
				}
			errno=0;
			clearerr(yyin);
			}
		}
    ]])
]])
#===================================================================
