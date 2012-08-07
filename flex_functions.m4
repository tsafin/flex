m4_dnl -*-C-*- vim:set ft=cxxm4:set noexpandtab cindent:

m4_if_cxx_only([[
/***************************************************************************/

/** M4_YY_LEX_CLASS constructor.
 * @param arg_yyin The initial input buffer.
 * @param arg_yyout The initial output buffer.
 * @result new M4_YY_LEX_CLASS object.
 */
M4_FUNC_DEF(,M4_YY_LEX_CLASS, M4_INSTREAM* in, M4_OUTSTREAM* out)
{
	init_globals();
	this->yyin = in;
	this->yyout = out;
}

/** M4_YY_LEX_CLASS destructor.
 */
M4_FUNC_DEF(,~M4_YY_LEX_CLASS)
{
	(void) yylex_destroy();
}

/* Definitions for additional C++-only functions. */
M4_FUNC_DEF(void, switch_streams, M4_INSTREAM* new_in, M4_OUTSTREAM* new_out)
{
	if ( new_in ) {
		yy_delete_buffer(YY_CURRENT_BUFFER);
		yy_switch_to_buffer(yy_create_buffer(new_in, YY_BUF_SIZE));
	}
	if ( new_out ) yyout = new_out;
}

    m4_if_cxx_streamio([[
M4_FUNC_DEF(int, LexerInput, char* buf, int max_size)
{
	if ( yyin->eof() || yyin->fail() ) return 0;
	if ( YY_CURRENT_BUFFER->is_interactive )
		{
		int n;
		for( n = 0; n < max_size; n++ )
			{
			buf[n] = yyin->get();
			if (buf[n] == '\n') return n+1;
			if ( yyin->eof() ) return n;
			if ( yyin->bad() )
				{
				YY_NONFATAL_ERROR("input in flex scanner failed");
				return -1;
				}
			}
		return n;
		}
	else
		{
		(void) yyin->read( buf, max_size );
		if ( yyin->bad() ) return -1;
		else return yyin->gcount();
		}
}
    ]],
    [[
M4_FUNC_DEF(int, LexerInput, char* buf, int max_size)
{
	int result;
M4_YY_INPUT()
	return result;
}
    ]])
]])m4_dnl endif C++ only

/* yy_get_next_buffer - try to read in a new buffer
 *
 * Returns a code representing an action:
 *	EOB_ACT_LAST_MATCH -
 *	EOB_ACT_CONTINUE_SCAN - continue scanning from current position
 *	EOB_ACT_END_OF_FILE - end of file
 */
M4_FUNC_DEF(static int, yy_get_next_buffer)
{
	register char *dest = YY_CURRENT_BUFFER->ch_buf;
	register char *source = yytext_ptr;
	register int number_to_move, i;
	int ret_val;

	if ( yy_c_buf_p > &YY_CURRENT_BUFFER->ch_buf[yy_n_chars + 1] )
		YY_FATAL_ERROR(
		"fatal flex scanner internal error--end of buffer missed");

	if ( YY_CURRENT_BUFFER->fill_buffer == 0 )
		{ /* Don't try to fill the buffer, so this is an EOF. */
		if ( yy_c_buf_p - yytext_ptr - YY_MORE_ADJ == 1 )
			{
			/* We matched a single character, the EOB, so
			 * treat this as a final EOF.
			 */
			return EOB_ACT_END_OF_FILE;
			}

		else
			{
			/* We matched some text prior to the EOB, first
			 * process it.
			 */
			return EOB_ACT_LAST_MATCH;
			}
		}

	/* Try to read more data. */

	/* First move last chars to start of buffer. */
	number_to_move = (int) (yy_c_buf_p - yytext_ptr) - 1;

	for( i = 0; i < number_to_move; ++i )
		*(dest++) = *(source++);

	if ( YY_CURRENT_BUFFER->buffer_status == YY_BUFFER_EOF_PENDING )
		/* don't do the read, it's not guaranteed to return an EOF,
		 * just force an EOF
		 */
		YY_CURRENT_BUFFER->n_chars = yy_n_chars = 0;

	else
		{
			int num_to_read =
			YY_CURRENT_BUFFER->buf_size - number_to_move - 1;

		while ( num_to_read <= 0 )
			{ /* Not enough room in the buffer - grow it. */
    m4_ifdef( [[M4_YY_USES_REJECT]],
    [[
			YY_FATAL_ERROR(
"input buffer overflow, can't enlarge buffer because scanner uses REJECT");
    ]],
    [[
			/* just a shorter name for the current buffer */
			YY_BUFFER_STATE b = YY_CURRENT_BUFFER;

			int yy_c_buf_p_offset =
				(int) (yy_c_buf_p - b->ch_buf);

			if ( b->is_our_buffer )
				{
				int new_size = b->buf_size * 2;

				if ( new_size <= 0 )
					b->buf_size += b->buf_size / 8;
				else
					b->buf_size *= 2;

				b->ch_buf = (char *)
					/* Include room in for 2 EOB chars. */
					yyrealloc( (void *) b->ch_buf,
							 b->buf_size + 2 );
				}
			else
				/* Can't grow it, we don't own it. */
				b->ch_buf = 0;

			if ( ! b->ch_buf )
				YY_FATAL_ERROR(
				"fatal error - scanner input buffer overflow");

			yy_c_buf_p = &b->ch_buf[yy_c_buf_p_offset];

			num_to_read = YY_CURRENT_BUFFER->buf_size -
						number_to_move - 1;
    ]])
			}

		if ( num_to_read > YY_READ_BUF_SIZE )
			num_to_read = YY_READ_BUF_SIZE;

		/* Read in more data. */
		YY_INPUT( (&YY_CURRENT_BUFFER->ch_buf[number_to_move]),
			yy_n_chars, (size_t) num_to_read );

		YY_CURRENT_BUFFER->n_chars = yy_n_chars;
		}

	if ( yy_n_chars == 0 )
		{
		if ( number_to_move == YY_MORE_ADJ )
			{
			ret_val = EOB_ACT_END_OF_FILE;
			yyrestart( yyin);
			}

		else
			{
			ret_val = EOB_ACT_LAST_MATCH;
			YY_CURRENT_BUFFER->buffer_status =
				YY_BUFFER_EOF_PENDING;
			}
		}

	else
		ret_val = EOB_ACT_CONTINUE_SCAN;

	if ((yy_size_t) (yy_n_chars + number_to_move) > YY_CURRENT_BUFFER->buf_size) {
		/* Extend the array by 50%, plus the number we really need. */
		yy_size_t new_size = yy_n_chars + number_to_move + (yy_n_chars >> 1);
		YY_CURRENT_BUFFER->ch_buf = (char *) yyrealloc(
			(void *) YY_CURRENT_BUFFER->ch_buf, new_size );
		if ( ! YY_CURRENT_BUFFER->ch_buf )
			YY_FATAL_ERROR("out of dynamic memory in yy_get_next_buffer()");
	}

	yy_n_chars += number_to_move;
	YY_CURRENT_BUFFER->ch_buf[yy_n_chars] = YY_END_OF_BUFFER_CHAR;
	YY_CURRENT_BUFFER->ch_buf[yy_n_chars + 1] = YY_END_OF_BUFFER_CHAR;

	yytext_ptr = &YY_CURRENT_BUFFER->ch_buf[0];

	return ret_val;
}

/* yy_get_previous_state - get the state just before the EOB char was reached */
M4_FUNC_DEF(static yy_state_type, yy_get_previous_state)
{
	register yy_state_type yy_current_state;
	register char *yy_cp;

M4_GEN_START_STATE()

	for( yy_cp = yytext_ptr + YY_MORE_ADJ; yy_cp < yy_c_buf_p; ++yy_cp )
	{
M4_GEN_NEXT_STATE(1)
	}

	return yy_current_state;
}


/* yy_try_NUL_trans - try to make a transition on the NUL character
 *
 * synopsis
 *	next_state = yy_try_NUL_trans( current_state );
 */
 /* NOTE: the reentrant object may be unreferenced, depending upon build options. */
M4_FUNC_DEF(static yy_state_type, yy_try_NUL_trans, yy_state_type yy_current_state)
{
	register int yy_is_jam;

M4_GEN_NUL_TRANSITION()

	return yy_is_jam ? 0 : yy_current_state;
}

m4_ifdef( [[M4_YY_NO_UNPUT]],,
[[
M4_FUNC_DEF(static void, yyunput, int c, register char *yy_bp)
{
	register char *yy_cp;

	if (!yy_init)
		yylex_init_state();

	yy_cp = yy_c_buf_p;

	/* undo effects of setting up yytext */
	*yy_cp = yy_hold_char;

	if ( yy_cp < YY_CURRENT_BUFFER->ch_buf + 2 )
		{ /* need to shift things up to make room */
		/* +2 for EOB chars. */
		register int number_to_move = yy_n_chars + 2;
		register char *dest = &YY_CURRENT_BUFFER->ch_buf[
					YY_CURRENT_BUFFER->buf_size + 2];
		register char *source =
				&YY_CURRENT_BUFFER->ch_buf[number_to_move];

		while ( source > YY_CURRENT_BUFFER->ch_buf )
			*--dest = *--source;

		yy_cp += (int) (dest - source);
		yy_bp += (int) (dest - source);
		YY_CURRENT_BUFFER->n_chars =
			yy_n_chars = YY_CURRENT_BUFFER->buf_size;

		if ( yy_cp < YY_CURRENT_BUFFER->ch_buf + 2 )
			YY_FATAL_ERROR("flex scanner push-back overflow");
		}

	*--yy_cp = (char) c;
m4_ifdef( [[M4_YY_USE_LINENO]],
[[
	if ( c == '\n' )
		M4_YY_DECR_LINENO();
]])
	yytext_ptr = yy_bp;
	yy_hold_char = *yy_cp;
	yy_c_buf_p = yy_cp;
}
]])

#ifndef YY_NO_INPUT
/* Function to read one character from the input stream */
M4_FUNC_DEF(static int, yyinput)
{
	int c;

	if (!yy_init)
		yylex_init_state();

	*yy_c_buf_p = yy_hold_char;

	if ( *yy_c_buf_p == YY_END_OF_BUFFER_CHAR )
		{
		/* yy_c_buf_p now points to the character we want to return.
		 * If this occurs *before* the EOB characters, then it's a
		 * valid NUL; if not, then we've hit the end of the buffer.
		 */
		if ( yy_c_buf_p < &YY_CURRENT_BUFFER->ch_buf[yy_n_chars] )
			/* This was really a NUL. */
			*yy_c_buf_p = '\0';

		else
			{ /* need more input */
			int offset = yy_c_buf_p - yytext_ptr;
			++yy_c_buf_p;

			switch( yy_get_next_buffer( ) )
				{
				case EOB_ACT_LAST_MATCH:
					/* This happens because yy_g_n_b()
					 * sees that we've accumulated a
					 * token and flags that we need to
					 * try matching the token before
					 * proceeding.  But for input(),
					 * there's no matching to consider.
					 * So convert the EOB_ACT_LAST_MATCH
					 * to EOB_ACT_END_OF_FILE.
					 */

					/* Reset buffer status. */
					yyrestart( yyin);

					/*FALLTHROUGH*/

				case EOB_ACT_END_OF_FILE:
					{
					if ( yywrap( ) )
						return EOF;

					if ( ! yy_did_buffer_switch_on_eof )
						YY_NEW_FILE;
					return input();
					}

				case EOB_ACT_CONTINUE_SCAN:
					yy_c_buf_p = yytext_ptr + offset;
					break;
				}
			}
		}

	c = *(unsigned char *) yy_c_buf_p;	/* cast for 8-bit char's */
	*yy_c_buf_p = '\0';	/* preserve yytext */
	yy_hold_char = *++yy_c_buf_p;
m4_ifdef( [[M4_YY_BOL_NEEDED]],
[[
	/* Update BOL inside of input(). */
	YY_CURRENT_BUFFER->at_bol = ( c == '\n' );
]])
m4_ifdef( [[M4_YY_USE_LINENO]],
[[
	/* Update yylineno inside of input(). */
	if ( c == '\n' )
		M4_YY_INCR_LINENO();
]])
	return c;
}
#endif	/* ifndef YY_NO_INPUT */

/** Immediately switch to a different input stream.
 * @param input_file A readable stream.
 * M4_YY_OBJECT_PARAM_DOC
 * @note This function does not reset the start condition to @c INITIAL .
 */
M4_FUNC_DEF(void, yyrestart, M4_INSTREAM *input_file)
{

	if ( ! YY_CURRENT_BUFFER )
	{
		yyensure_buffer_stack();
		YY_CURRENT_BUFFER_LVALUE =
			yy_create_buffer( yyin, YY_BUF_SIZE);
	}

	yy_init_buffer( YY_CURRENT_BUFFER, input_file);
	yy_load_buffer_state( );
}

/** Switch to a different input buffer.
 * @param new_buffer The new input buffer.
 * M4_YY_OBJECT_PARAM_DOC
 */
M4_FUNC_DEF(void, yy_switch_to_buffer, YY_BUFFER_STATE new_buffer)
{

	/* TODO. We should be able to replace this entire function body
	 * with
	 *		yypop_buffer_state();
	 *		yypush_buffer_state(new_buffer);
     */
	yyensure_buffer_stack();
	if ( YY_CURRENT_BUFFER_LVALUE == new_buffer )
		return;

	if ( YY_CURRENT_BUFFER )
	{
		/* Flush out information for old buffer. */
		*yy_c_buf_p = yy_hold_char;
		YY_CURRENT_BUFFER->buf_pos = yy_c_buf_p;
		YY_CURRENT_BUFFER->n_chars = yy_n_chars;
	}

	YY_CURRENT_BUFFER_LVALUE = new_buffer;
	yy_load_buffer_state( );

	/* We don't actually know whether we did this switch during
	 * EOF (yywrap()) processing, but the only time this flag
	 * is looked at is after yywrap() is called, so it's safe
	 * to go ahead and always set it.
	 */
	yy_did_buffer_switch_on_eof = 1;
}

M4_FUNC_DEF(static void, yy_load_buffer_state)
{
	yy_n_chars = YY_CURRENT_BUFFER->n_chars;
	yytext_ptr = yy_c_buf_p = YY_CURRENT_BUFFER->buf_pos;
	yyin = YY_CURRENT_BUFFER->input_file;
	yy_hold_char = *yy_c_buf_p;
}

/** Allocate and initialize an input buffer state.
 * @param file A readable stream.
 * @param size The character buffer size in bytes. When in doubt, use @c YY_BUF_SIZE.
 * M4_YY_OBJECT_PARAM_DOC
 * @return the allocated buffer state.
 */
M4_FUNC_DEF(YY_BUFFER_STATE, yy_create_buffer, M4_INSTREAM *file, int size)
{
	YY_BUFFER_STATE b;

	b = (YY_BUFFER_STATE) yyalloc( sizeof( struct yy_buffer_state ) );
	if ( ! b )
		YY_FATAL_ERROR("out of dynamic memory in yy_create_buffer()");

	b->buf_size = size;

	/* yy_ch_buf has to be 2 characters longer than the size given because
	 * we need to put in 2 end-of-buffer characters.
	 */
	b->ch_buf = (char *) yyalloc( b->buf_size + 2 );
	if ( ! b->ch_buf )
		YY_FATAL_ERROR("out of dynamic memory in yy_create_buffer()");

	b->is_our_buffer = 1;

	yy_init_buffer( b, file);

	return b;
}

/** Destroy the buffer.
 * @param b a buffer created with yy_create_buffer()
 * M4_YY_OBJECT_PARAM_DOC
 */
M4_FUNC_DEF(void, yy_delete_buffer, YY_BUFFER_STATE b)
{

	if ( ! b )
		return;

	if ( b == YY_CURRENT_BUFFER ) /* Not sure if we should pop here. */
		YY_CURRENT_BUFFER_LVALUE = (YY_BUFFER_STATE) 0;

	if ( b->is_our_buffer )
		yyfree( (void *) b->ch_buf );

	yyfree( (void *) b );
}


/* Initializes or reinitializes a buffer.
 * This function is sometimes called more than once on the same buffer,
 * such as during a yyrestart() or at EOF.
 */
M4_FUNC_DEF(static void, yy_init_buffer, YY_BUFFER_STATE b, M4_INSTREAM * file)
{
	int oerrno = errno;

	yy_flush_buffer( b);

	b->input_file = file;
	b->fill_buffer = 1;

    /* If b is the current buffer, then yy_init_buffer was _probably_
     * called from yyrestart() or through yy_get_next_buffer.
     * In that case, we don't want to reset the lineno or column.
     */
    if (b != YY_CURRENT_BUFFER){
	b->bs_lineno = 1;
	b->bs_column = 0;
    }

m4_ifdef( [[M4_YY_ALWAYS_INTERACTIVE]],
[[
	b->is_interactive = 1;
]],
[[
    m4_ifdef( [[M4_YY_NEVER_INTERACTIVE]],
    [[
	b->is_interactive = 0;
    ]],
    [[
	b->is_interactive = YY_ISATTY(file);
    ]])
]])
	errno = oerrno;
}

/** Discard all buffered characters. On the next scan, YY_INPUT will be called.
 * @param b the buffer state to be flushed, usually @c YY_CURRENT_BUFFER.
 * M4_YY_OBJECT_PARAM_DOC
 */
M4_FUNC_DEF(void, yy_flush_buffer, YY_BUFFER_STATE b)
{
	if ( ! b )
		return;

	b->n_chars = 0;

	/* We always need two end-of-buffer characters.  The first causes
	 * a transition to the end-of-buffer state.  The second causes
	 * a jam in that state.
	 */
	b->ch_buf[0] = YY_END_OF_BUFFER_CHAR;
	b->ch_buf[1] = YY_END_OF_BUFFER_CHAR;

	b->buf_pos = &b->ch_buf[0];

	b->at_bol = 1;
	b->buffer_status = YY_BUFFER_NEW;

	if ( b == YY_CURRENT_BUFFER )
		yy_load_buffer_state( );
}

/** Pushes the new state onto the stack. The new state becomes
 *  the current state. This function will allocate the stack
 *  if necessary.
 *  @param new_buffer The new state.
 *  M4_YY_OBJECT_PARAM_DOC
 */
M4_FUNC_DEF(void, yypush_buffer_state, YY_BUFFER_STATE new_buffer)
{
	if (new_buffer == NULL)
		return;

	yyensure_buffer_stack();

	/* This block is copied from yy_switch_to_buffer. */
	if ( YY_CURRENT_BUFFER )
		{
		/* Flush out information for old buffer. */
		*yy_c_buf_p = yy_hold_char;
		YY_CURRENT_BUFFER->buf_pos = yy_c_buf_p;
		YY_CURRENT_BUFFER->n_chars = yy_n_chars;
		}

	/* Only push if top exists. Otherwise, replace top. */
	if (YY_CURRENT_BUFFER)
		yy_buffer_stack_top++;
	YY_CURRENT_BUFFER_LVALUE = new_buffer;

	/* copied from yy_switch_to_buffer. */
	yy_load_buffer_state( );
	yy_did_buffer_switch_on_eof = 1;
}

/** Removes and deletes the top of the stack, if present.
 *  The next element becomes the new top.
 *  M4_YY_OBJECT_PARAM_DOC
 */
M4_FUNC_DEF(void, yypop_buffer_state)
{
	if (!YY_CURRENT_BUFFER)
		return;

	yy_delete_buffer(YY_CURRENT_BUFFER);
	YY_CURRENT_BUFFER_LVALUE = NULL;
	if (yy_buffer_stack_top > 0)
		--yy_buffer_stack_top;

	if (YY_CURRENT_BUFFER) {
		yy_load_buffer_state( );
		yy_did_buffer_switch_on_eof = 1;
	}
}

/* Allocates the stack if it does not exist.
 *  Guarantees space for at least one push.
 */
M4_FUNC_DEF(static void, yyensure_buffer_stack)
{
	int num_to_alloc;

	if (!yy_buffer_stack) {

		/* First allocation is just for 2 elements, since we don't know if this
		 * scanner will even need a stack. We use 2 instead of 1 to avoid an
		 * immediate realloc on the next call.
	 */
		num_to_alloc = 1;
		yy_buffer_stack = (struct yy_buffer_state**)
			yyalloc(num_to_alloc * sizeof(struct yy_buffer_state*));

		if ( ! yy_buffer_stack )
			YY_FATAL_ERROR("out of dynamic memory in yyensure_buffer_stack()");


		memset(yy_buffer_stack, 0, num_to_alloc * sizeof(struct yy_buffer_state*));

		yy_buffer_stack_max = num_to_alloc;
		yy_buffer_stack_top = 0;
		return;
	}

	if (yy_buffer_stack_top >= (yy_buffer_stack_max) - 1){

		/* Increase the buffer to prepare for a possible push. */
		int grow_size = 8 /* arbitrary grow size */;

		num_to_alloc = yy_buffer_stack_max + grow_size;
		yy_buffer_stack = (struct yy_buffer_state**)
			yyrealloc(yy_buffer_stack,
			num_to_alloc * sizeof(struct yy_buffer_state*));

		if ( ! yy_buffer_stack )
			YY_FATAL_ERROR("out of dynamic memory in yyensure_buffer_stack()");

		/* zero only the new slots.*/
		memset(yy_buffer_stack + yy_buffer_stack_max, 0, grow_size * sizeof(struct yy_buffer_state*));
		yy_buffer_stack_max = num_to_alloc;
	}
}


m4_if_c_only([[
m4_ifdef( [[M4_YY_NO_SCAN_BUFFER]],,
[[
/** Setup the input buffer state to scan directly from a user-specified character buffer.
 * @param base the character buffer
 * @param size the size in bytes of the character buffer
 * M4_YY_OBJECT_PARAM_DOC
 * @return the newly allocated buffer state object. 
 */
M4_FUNC_DEF(YY_BUFFER_STATE, yy_scan_buffer, char * base, yy_size_t size)
{
	YY_BUFFER_STATE b;

	if ( size < 2 ||
	     base[size-2] != YY_END_OF_BUFFER_CHAR ||
	     base[size-1] != YY_END_OF_BUFFER_CHAR )
		/* They forgot to leave room for the EOB's. */
		return 0;

	b = (YY_BUFFER_STATE) yyalloc( sizeof( struct yy_buffer_state ) );
	if ( ! b )
		YY_FATAL_ERROR("out of dynamic memory in yy_scan_buffer()");

	b->buf_size = size - 2;	/* "- 2" to take care of EOB's */
	b->buf_pos = b->ch_buf = base;
	b->is_our_buffer = 0;
	b->input_file = 0;
	b->n_chars = b->buf_size;
	b->is_interactive = 0;
	b->at_bol = 1;
	b->fill_buffer = 0;
	b->buffer_status = YY_BUFFER_NEW;

	yy_switch_to_buffer( b );

	return b;
}
]])


m4_ifdef( [[M4_YY_NO_SCAN_STRING]],,
[[
/** Setup the input buffer state to scan a string. The next call to yylex() will
 * scan from a @e copy of @a str.
 * @param yystr a NUL-terminated string to scan
 * M4_YY_OBJECT_PARAM_DOC
 * @return the newly allocated buffer state object.
 * @note If you want to scan bytes that may contain NUL values, then use
 *       yy_scan_bytes() instead.
 */
M4_FUNC_DEF(YY_BUFFER_STATE, yy_scan_string, const char * yystr)
{

	return yy_scan_bytes( yystr, strlen(yystr));
}
]])


m4_ifdef( [[M4_YY_NO_SCAN_BYTES]],,
[[
/** Setup the input buffer state to scan the given bytes. The next call to yylex() will
 * scan from a @e copy of @a bytes.
 * @param bytes the byte buffer to scan
 * @param len the number of bytes in the buffer pointed to by @a bytes.
 * M4_YY_OBJECT_PARAM_DOC
 * @return the newly allocated buffer state object.
 */
M4_FUNC_DEF(YY_BUFFER_STATE, yy_scan_bytes, const char * yybytes, int _yybytes_len)
{
	YY_BUFFER_STATE b;
	char *buf;
	yy_size_t n;
	int i;

	/* Get memory for full buffer, including space for trailing EOB's. */
	n = _yybytes_len + 2;
	buf = (char *) yyalloc( n );
	if ( ! buf )
		YY_FATAL_ERROR("out of dynamic memory in yy_scan_bytes()");

	for( i = 0; i < _yybytes_len; ++i )
		buf[i] = yybytes[i];

	buf[_yybytes_len] = buf[_yybytes_len+1] = YY_END_OF_BUFFER_CHAR;

	b = yy_scan_buffer( buf, n);
	if ( ! b )
		YY_FATAL_ERROR("bad buffer in yy_scan_bytes()");

	/* It's okay to grow etc. this buffer, and we should throw it
	 * away when we're done.
	 */
	b->is_our_buffer = 1;

	return b;
}
]])
]])


m4_ifdef( [[M4_YY_NO_PUSH_STATE]],,
[[
M4_FUNC_DEF(static void, yy_push_state, int new_state)
{
	if ( yy_start_stack_ptr >= yy_start_stack_depth )
		{
		yy_size_t new_size;

		yy_start_stack_depth += YY_START_STACK_INCR;
		new_size = yy_start_stack_depth * sizeof( int );

		if ( ! yy_start_stack )
			yy_start_stack = (int *) yyalloc( new_size );

		else
			yy_start_stack = (int *) yyrealloc(
					(void *) yy_start_stack, new_size );

		if ( ! yy_start_stack )
			YY_FATAL_ERROR("out of memory expanding start-condition stack");
		}

	yy_start_stack[yy_start_stack_ptr++] = YY_START;

	BEGIN(new_state);
}
]])


m4_ifdef( [[M4_YY_NO_POP_STATE]],,
[[
M4_FUNC_DEF(static void, yy_pop_state)
{
	if ( --yy_start_stack_ptr < 0 )
		YY_FATAL_ERROR("start-condition stack underflow");

	BEGIN(yy_start_stack[yy_start_stack_ptr]);
}
]])


m4_ifdef( [[M4_YY_NO_TOP_STATE]],,
[[
M4_FUNC_DEF(static int, yy_top_state)
{
	return yy_start_stack[yy_start_stack_ptr - 1];
}
]])

m4_if_cxx_only([[
M4_FUNC_DEF_NG(static void, LexerClassError, const char* msg)
{
m4_if_cxx_streamio([[
	std::cerr << msg << std::endl;
]],
[[
	(void) fprintf( stderr, "%s\n", msg );
]])
	exit( YY_EXIT_FAILURE );
}
]])

M4_FUNC_DEF(static void, yy_fatal_error, const char* msg)
{
m4_if_cxx_streamio([[
	std::cerr << msg << std::endl;
]],
[[
	(void) fprintf( stderr, "%s\n", msg );
]])
	exit( YY_EXIT_FAILURE );
}

/* Accessor  methods(get/set functions) to struct members. */

m4_ifdef( [[M4_YY_NO_GET_EXTRA]],,
[[
/** Get the user-defined data for this scanner.
 * M4_YY_OBJECT_PARAM_DOC
 */
M4_FUNC_DEF(YY_EXTRA_TYPE, yyget_extra)
{
    return yyextra;
}
]])

m4_ifdef( [[M4_YY_NO_GET_LINENO]],,
[[
/** Get the current line number.
 * M4_YY_OBJECT_PARAM_DOC
 */
M4_FUNC_DEF(int, yyget_lineno)
{

    m4_if_reentrant([[
	if (! YY_CURRENT_BUFFER)
	    return 0;
    ]])
    return yylineno;
}
]])

m4_ifdef( [[M4_YY_NO_GET_COLUMN]],,
[[
/** Get the current column number.
 * M4_YY_OBJECT_PARAM_DOC
 */
M4_FUNC_DEF(int, yyget_column)
{

    m4_if_reentrant([[
	if (! YY_CURRENT_BUFFER)
	    return 0;
    ]])
    return yycolumn;
}
]])

m4_ifdef( [[M4_YY_NO_GET_IN]],,
[[
/** Get the input stream.
 * M4_YY_OBJECT_PARAM_DOC
 */
M4_FUNC_DEF(M4_INSTREAM *, yyget_in)
{
    return yyin;
}
]])

m4_ifdef( [[M4_YY_NO_GET_OUT]],,
[[
/** Get the output stream.
 * M4_YY_OBJECT_PARAM_DOC
 */
M4_FUNC_DEF(M4_OUTSTREAM *, yyget_out)
{
    return yyout;
}
]])

m4_ifdef( [[M4_YY_NO_GET_LENG]],,
[[
/** Get the length of the current token.
 * M4_YY_OBJECT_PARAM_DOC
 */
M4_FUNC_DEF(int, yyget_leng)
{
    return yyleng;
}
]])

/** Get the current token.
 * M4_YY_OBJECT_PARAM_DOC
 */
m4_ifdef( [[M4_YY_NO_GET_TEXT]],,
[[
M4_FUNC_DEF(char *, yyget_text)
{
    return yytext;
}
]])

m4_ifdef( [[M4_YY_NO_SET_EXTRA]],,
[[
/** Set the user-defined data. This data is never touched by the scanner.
 * @param user_defined The data to be associated with this scanner.
 * M4_YY_OBJECT_PARAM_DOC
 */
M4_FUNC_DEF(void, yyset_extra, YY_EXTRA_TYPE user_defined)
{
    yyextra = user_defined ;
}
]])

m4_ifdef( [[M4_YY_NO_SET_LINENO]],,
[[
/** Set the current line number.
 * @param line_number
 * M4_YY_OBJECT_PARAM_DOC
 */
M4_FUNC_DEF(void, yyset_lineno, int line_number)
{

    m4_if_reentrant([[
	/* lineno is only valid if an input buffer exists. */
	if (! YY_CURRENT_BUFFER )
	   YY_FATAL_ERROR("yyset_lineno called with no buffer"); 
    ]])
    yylineno = line_number;
}
]])

m4_ifdef( [[M4_YY_NO_SET_COLUMN]],,
[[
/** Set the current column.
 * @param line_number
 * M4_YY_OBJECT_PARAM_DOC
 */
M4_FUNC_DEF(void, yyset_column, int column_no)
{

    m4_if_reentrant([[
	/* column is only valid if an input buffer exists. */
	if (! YY_CURRENT_BUFFER )
	   YY_FATAL_ERROR("yyset_column called with no buffer"); 
    ]])
    yycolumn = column_no;
}
]])


m4_ifdef( [[M4_YY_NO_SET_IN]],,
[[
/** Set the input stream. This does not discard the current
 * input buffer.
 * @param in_str A readable stream.
 * M4_YY_OBJECT_PARAM_DOC
 * @see yy_switch_to_buffer
 */
M4_FUNC_DEF(void, yyset_in, M4_INSTREAM * in_str)
{
    yyin = in_str ;
}
]])

m4_ifdef( [[M4_YY_NO_SET_OUT]],,
[[
M4_FUNC_DEF(void, yyset_out, M4_OUTSTREAM * out_str)
{
    yyout = out_str ;
}
]])


m4_ifdef( [[M4_YY_NO_GET_DEBUG]],,
[[
M4_FUNC_DEF(int, yyget_debug)
{
    return yy_flex_debug;
}
]])

m4_ifdef( [[M4_YY_NO_SET_DEBUG]],,
[[
M4_FUNC_DEF(void, yyset_debug, int bdebug)
{
    yy_flex_debug = bdebug ;
}
]])

m4_ifdef( [[M4_YY_NO_GET_LVAL]],,
[[
M4_FUNC_DEF(YYSTYPE *, yyget_lval)
{
    return yylval;
}
]])

m4_ifdef( [[M4_YY_NO_SET_LVAL]],,
[[
M4_FUNC_DEF(void, yyset_lval, YYSTYPE * yylval_param)
{
    yylval = yylval_param;
}
]])

m4_ifdef( [[M4_YY_NO_GET_LLOC]],,
[[
M4_FUNC_DEF(YYLTYPE *, yyget_lloc)
{
    return yylloc;
}
]])

m4_ifdef( [[M4_YY_NO_SET_LLOC]],,
[[
M4_FUNC_DEF(void, yyset_lloc, YYLTYPE * yylloc_param)
{
    yylloc = yylloc_param;
}
]])


/* User-visible API */
m4_if_reentrant([[
/* yylex_init creates the scanner object itself (a constructor).
 * It follows the convention of taking the scanner as the last argument, but
 * it is a *pointer* to a scanner, and will be allocated by this call.
 */
M4_FUNC_DEF_NG(int, yylex_init, yyscan_t *yyscanner_return)
{
    yyscan_t yyscanner;

    if (yyscanner_return == 0){
	errno = EINVAL;
	return 1;
    }
/* yyscanner may be invalid here, unless called from yylex_init_extra.
 * If yyalloc() is user-defined, and references the yyscanner object,
 * you must use yylex_init_extra().
 */
    yyscanner = *yyscanner_return;

    *yyscanner_return = (yyscan_t) yyalloc( sizeof( struct yyobject_t ));

    if (*yyscanner_return == 0){
	errno = ENOMEM;
	return 1;
    }

/* Assign yyscanner to the actual yyscanner object, for use by yy_init_globals */
    yyscanner = *yyscanner_return;

    /* By setting to 0xAA, we expose bugs in yy_init_globals. Leave at 0x00 for releases. */
m4_ifdef( [[M4_DEBUG_BUILD]],
[[
    memset(yyscanner,0xAA,sizeof(struct yyobject_t));
]],
[[
    memset(yyscanner,0x00,sizeof(struct yyobject_t));
]])

    return yy_init_globals();
}


/* yylex_init_extra has the same functionality as yylex_init, but includes
 * an argument to initialize the yyextra pointer. This version is required
 * if you supply a yyalloc() function that references the yyextra pointer.
 */
M4_FUNC_DEF_NG(int, yylex_init_extra, YY_EXTRA_TYPE user_defined, yyscan_t *yyscanner_return)
{
    struct yyobject_t dummy_object;
    int status;

    yyscan_t yyscanner = (yyscan_t)&dummy_object;
    yyset_extra(user_defined);
    status = yylex_init(&yyscanner);

    if (!status) {
    	yyset_extra(user_defined);
	*yyscanner_return = yyscanner;
    }

    return status;
}
]])m4_dnl end if reentrant

M4_FUNC_DEF(static int, yy_init_globals)
{
    /* Initialization is the same as for the non-reentrant scanner.
     * This function is called from yylex_destroy(), so don't allocate here.
     * (Which means that is essentially impossible to get an error here.)
     */
M4_GLOBALS_INIT()
    /* For future reference: Set errno on error, since we are called by
     * yylex_init(). Currently, no errors are possible. It would be good
     * to allocate buffers, but those functions use YY_FATAL_ERROR() instead
     * of returning error codes, so it will take a bit of re-writing.
     */
    return 0;
}

M4_FUNC_DEF(void, yylex_init_state) {
	if (! (yy_init & YYLEX_INIT_STATE)) {
m4_ifdef( [[M4_YY_USES_REJECT]],
[[
	/* Create the reject buffer large enough to save one state per allowed character. */
		if ( ! yy_state_buf )
			yy_state_buf = (yy_state_type *)yyalloc(YY_STATE_BUF_SIZE);
		if ( ! yy_state_buf )
			YY_FATAL_ERROR("out of dynamic memory in yylex()");
]])
		if ( ! yy_start )
			BEGIN(INITIAL);	/* first start state */

		if ( ! yyin )
			yyin = M4_STDIN;

		if ( ! yyout )
			yyout = M4_STDOUT;

		if ( ! YY_CURRENT_BUFFER ) {
			yyensure_buffer_stack();
			YY_CURRENT_BUFFER_LVALUE =
				yy_create_buffer( yyin, YY_BUF_SIZE);
		}

		yy_load_buffer_state( );

		yy_init |= YYLEX_INIT_STATE;
	}
}

/* yylex_destroy is for both reentrant and non-reentrant scanners. */
M4_FUNC_DEF(int, yylex_destroy)
{

    /* Pop the buffer stack, destroying each element. */
	while (YY_CURRENT_BUFFER){
		yy_delete_buffer( YY_CURRENT_BUFFER );
		YY_CURRENT_BUFFER_LVALUE = NULL;
		yypop_buffer_state();
	}

	/* Destroy the stack itself. */
	yyfree(yy_buffer_stack);
	yy_buffer_stack = NULL;
m4_ifdef( [[M4_YY_STACK_USED]],
[[
	/* Destroy the start condition stack. */
	yyfree( yy_start_stack );
	yy_start_stack = NULL;
]])
m4_ifdef( [[M4_YY_USES_REJECT]],
[[
	yyfree( yy_state_buf);
	yy_state_buf  = NULL;
]])
m4_if_c_only([[
    m4_if_reentrant([[
    /* Destroy the main struct(reentrant only). */
    yyfree( yyscanner );
    ]],
    [[
    /* Reset the globals. This is important in a non-reentrant scanner so the next time
     * yylex() is called, initialization will occur. */
    yy_init_globals();
    ]])
]])
    return 0;
}


/*
 * Internal utility routines.
 */
m4_dnl This assumes that C++ always has these functions.
m4_if_c_only([[
m4_ifdef( [[M4_YY_TEXT_IS_ARRAY]],
[[
M4_FUNC_DEF_NG(static void, yy_flex_strncpy, char* s1, const char *s2, unsigned int nmax)
{
	register unsigned int i;
	for( i = 0; i < nmax; ++i )
		s1[i] = s2[i];
}
]])

#ifdef YY_NEED_STRLEN
M4_FUNC_DEF_NG(static int, yy_flex_strlen, const char *s)
{
	register int n;
	for( n = 0; s[n]; ++n )
		;

	return n;
}
#endif
]])

m4_ifdef( [[M4_YY_NO_FLEX_ALLOC]],,
[[
M4_FUNC_DEF(void *, yyalloc, yy_size_t size)
{
	return(void *) malloc( size );
}
]])

m4_ifdef( [[M4_YY_NO_FLEX_REALLOC]],,
[[
M4_FUNC_DEF(void *, yyrealloc, void *ptr, yy_size_t size)
{
	/* The cast to(char *) in the following accommodates both
	 * implementations that use char* generic pointers, and those
	 * that use void* generic pointers.  It works with the latter
	 * because both ANSI C and C++ allow castless assignment from
	 * any pointer type to void*, and deal with argument conversions
	 * as though doing an assignment.
	 */
	return(void *) realloc( (char *) ptr, size );
}
]])

m4_ifdef( [[M4_YY_NO_FLEX_FREE]],,
[[
M4_FUNC_DEF(void, yyfree, void *ptr)
{
	free( (char *) ptr );	/* see yyrealloc() for(char *) cast */
}
]])

m4_if_tables_serialization([[
m4_dnl File contains code for yytbl_calc_total_len(const struct yytbl_data *tbl)
/* From tables_shared.c */

/** Get the number of integers in this table. This is NOT the
 *  same thing as the number of elements.
 *  @param td the table 
 *  @return the number of integers in the table
 */
M4_FUNC_DEF_NG(static flex_int32_t, yytbl_calc_total_len, const struct yytbl_data *tbl)
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

M4_FUNC_DEF_NG(static int, yytbl_read8, void *v, struct yytbl_reader * rd)
{
    errno = 0;
m4_if_cxx_streamio([[
    rd->fp->read((char*)v, sizeof(flex_uint8_t));
    if (rd->fp->bad())
]],
[[
    if (fread(v, sizeof(flex_uint8_t), 1, rd->fp) != 1)
]])
    {
	errno = EIO;
	return -1;
    }
    rd->bread += sizeof(flex_uint8_t);
    return 0;
}

M4_FUNC_DEF_NG(static int, yytbl_read16, void *v, struct yytbl_reader * rd)
{
    errno = 0;
m4_if_cxx_streamio([[
    rd->fp->read((char*)v, sizeof(flex_uint16_t));
    if (rd->fp->bad())
]],
[[
    if (fread(v, sizeof(flex_uint16_t), 1, rd->fp) != 1)
]])
    {
	errno = EIO;
	return -1;
    }
    *((flex_uint16_t *) v) = ntohs(*((flex_uint16_t *) v));
    rd->bread += sizeof(flex_uint16_t);
    return 0;
}

M4_FUNC_DEF_NG(static int, yytbl_read32, void *v, struct yytbl_reader * rd)
{
    errno = 0;
m4_if_cxx_streamio([[
    rd->fp->read((char*)v, sizeof(flex_uint32_t));
    if (rd->fp->bad())
]],
[[
    if (fread(v, sizeof(flex_uint32_t), 1, rd->fp) != 1)
]])
    {
	errno = EIO;
	return -1;
    }
    *((flex_uint32_t *) v) = ntohl(*((flex_uint32_t *) v));
    rd->bread += sizeof(flex_uint32_t);
    return 0;
}

/** Read the header */
M4_FUNC_DEF(static int, yytbl_hdr_read, struct yytbl_hdr * th, struct yytbl_reader * rd)
{
    int     bytes;
    memset(th, 0, sizeof(struct yytbl_hdr));

    if (yytbl_read32 (&(th->th_magic), rd) != 0)
	return -1;

    if (th->th_magic != YYTBL_MAGIC){
	M4_YY_GLOBAL_NONFATAL_ERROR("bad magic number");
	return -1;
    }

    if (yytbl_read32 (&(th->th_hsize), rd) != 0
	|| yytbl_read32 (&(th->th_ssize), rd) != 0
	|| yytbl_read16 (&(th->th_flags), rd) != 0)
	return -1;

    /* Sanity check on header size. Greater than 1k suggests some funny business. */
    if (th->th_hsize < 16 || th->th_hsize > 1024){
	M4_YY_GLOBAL_NONFATAL_ERROR("insane header size detected");
	return -1;
    }

    /* Allocate enough space for the version and name fields */
    bytes = th->th_hsize - 14;
    th->th_version = (char *) yyalloc(bytes);
    if ( ! th->th_version )
	M4_YY_GLOBAL_FATAL_ERROR("out of dynamic memory in yytbl_hdr_read()");

    /* we read it all into th_version, and point th_name into that data */
m4_if_cxx_streamio([[
    rd->fp->read(th->th_version,bytes);
    if (rd->fp->gcount() != bytes) {
]],
[[
    if (fread(th->th_version, 1, bytes, rd->fp) != bytes){
]])
	errno = EIO;
	yyfree(th->th_version);
	th->th_version = NULL;
	return -1;
    }
    else
	rd->bread += bytes;

    th->th_name = th->th_version + strlen(th->th_version) + 1;
    return 0;
}

/** lookup id in the dmap list.
 *  @param dmap pointer to first element in list
 *  @return NULL if not found.
 */
M4_FUNC_DEF(static struct yytbl_dmap *, yytbl_dmap_lookup, struct yytbl_dmap *dmap, int id)
{
    while (dmap->dm_id)
	if (dmap->dm_id == id)
	    return dmap;
	else
	    dmap++;
    return NULL;
}

/** Read a table while mapping its contents to the local array. 
 *  @param dmap used to performing mapping
 *  @return 0 on success
 */
M4_FUNC_DEF(static int, yytbl_data_load, struct yytbl_dmap * dmap, struct yytbl_reader* rd)
{
    struct yytbl_data td;
    struct yytbl_dmap *transdmap=0;
    int     len, i, rv, inner_loop_count;
    void   *p=0;

    memset((void*)&td, 0, sizeof(struct yytbl_data));

    if (yytbl_read16 (&td.td_id, rd) != 0
	|| yytbl_read16 (&td.td_flags, rd) != 0
	|| yytbl_read32 (&td.td_hilen, rd) != 0
	|| yytbl_read32 (&td.td_lolen, rd) != 0)
	return -1;

    /* Lookup the map for the transition table so we have it in case we need it
     * inside the loop below. This scanner might not even have a transition
     * table, which is ok.
     */
    transdmap = yytbl_dmap_lookup(dmap, YYTD_ID_TRANSITION);

    if ((dmap = yytbl_dmap_lookup(dmap, td.td_id)) == NULL){
	M4_YY_GLOBAL_NONFATAL_ERROR("table id not found in map.");
	return -1;
    }

    /* Allocate space for table.
     * The --full yy_transition table is a special case, since we
     * need the dmap.dm_sz entry to tell us the sizeof the individual
     * struct members.
     */
    {
    size_t  bytes;

    bytes = td.td_lolen * (td.td_hilen ? td.td_hilen : 1) * dmap->dm_sz;

    if (M4_YY_TABLES_VERIFY)
	/* We point to the array itself */
	p = dmap->dm_arr; 
    else
	/* We point to the address of a pointer. */
	*dmap->dm_arr = p = (void *) yyalloc(bytes);
	if ( ! p )
	    M4_YY_GLOBAL_FATAL_ERROR("out of dynamic memory in yytbl_data_load()");
    }

    /* If it's a struct, we read 2 integers to get one element */
    if ((td.td_flags & YYTD_STRUCT) != 0)
	inner_loop_count = 2;
    else
	inner_loop_count = 1;

    /* read and map each element.
     * This loop iterates once for each element of the td_data array.
     * Notice that we increment 'i' in the inner loop.
     */
    len = yytbl_calc_total_len(&td);
    for(i = 0; i < len; ){
	int    j;


	/* This loop really executes exactly 1 or 2 times.
	 * The second time is to handle the second member of the
	 * YYTD_STRUCT for the yy_transition array.
	 */
	for(j = 0; j < inner_loop_count; j++, i++) {
	    flex_int32_t t32;

	    /* read into t32 no matter what the real size is. */
	    {
		flex_int16_t t16;
		flex_int8_t  t8;

		switch(YYTDFLAGS2BYTES (td.td_flags)) {
		case sizeof(flex_int32_t):
		    rv = yytbl_read32 (&t32, rd);
		    break;
		case sizeof(flex_int16_t):
		    rv = yytbl_read16 (&t16, rd);
		    t32 = t16;
		    break;
		case sizeof(flex_int8_t):
		    rv = yytbl_read8 (&t8, rd);
		    t32 = t8;
		    break;
		default: 
		    M4_YY_GLOBAL_NONFATAL_ERROR("invalid td_flags");
		    return -1;
		}
	    }
	    if (rv != 0)
		return -1;

	    /* copy into the deserialized array... */

	    if ((td.td_flags & YYTD_STRUCT)) {
		/* t32 is the j'th member of a two-element struct. */
		void   *v;

		v = j == 0 ? &(((struct yy_trans_info *) p)->yy_verify)
		    : &(((struct yy_trans_info *) p)->yy_nxt);

		switch(dmap->dm_sz) {
m4_if([[M4_YY_TABLES_VERIFY]],[[m4_dnl
		case (2*sizeof(flex_int32_t)):
			if ( ((flex_int32_t *) v)[0] != (flex_int32_t) t32)
			   M4_YY_GLOBAL_FATAL_ERROR("tables verification failed at YYTD_STRUCT flex_int32_t");
		    break;
		case (2*sizeof(flex_int16_t)):
			if (((flex_int16_t *) v)[0] != (flex_int16_t) t32)
			    M4_YY_GLOBAL_FATAL_ERROR("tables verification failed at YYTD_STRUCT flex_int16_t");
		    break;
		case (2*sizeof(flex_int8_t)):
			 if ( ((flex_int8_t *) v)[0] != (flex_int8_t) t32)
			    M4_YY_GLOBAL_FATAL_ERROR("tables verification failed at YYTD_STRUCT flex_int8_t");
		    break;
]],[[m4_dnl
		case (2*sizeof(flex_int32_t)):
			((flex_int32_t *) v)[0] = (flex_int32_t) t32;
		    break;
		case (2*sizeof(flex_int16_t)):
			((flex_int16_t *) v)[0] = (flex_int16_t) t32;
		    break;
		case (2*sizeof(flex_int8_t)):
			((flex_int8_t *) v)[0] = (flex_int8_t) t32;
		    break;
]])m4_dnl
		default:
		    M4_YY_GLOBAL_FATAL_ERROR("invalid dmap->dm_sz for struct");
		    return -1;
		}

		/* if we're done with j, increment p */
		if (j == 1)
		    p = (struct yy_trans_info *) p + 1;
	    }
	    else if ((td.td_flags & YYTD_PTRANS)) {
		/* t32 is an index into the transition array. */
		struct yy_trans_info *v;


		if (!transdmap){
		    M4_YY_GLOBAL_NONFATAL_ERROR("transition table not found");
		    return -1;
		}

		if ( M4_YY_TABLES_VERIFY)
		    v = &(((struct yy_trans_info *) (transdmap->dm_arr))[t32]);
		else
		    v = &((*((struct yy_trans_info **) (transdmap->dm_arr)))[t32]);

		if (M4_YY_TABLES_VERIFY ){
		    if ( ((struct yy_trans_info **) p)[0] != v)
			M4_YY_GLOBAL_FATAL_ERROR("tables verification failed at YYTD_PTRANS");
		}else
		    ((struct yy_trans_info **) p)[0] = v;

		/* increment p */
		p = (struct yy_trans_info **) p + 1;
	    }
	    else {
		/* t32 is a plain int. copy data, then incrememnt p. */
		switch(dmap->dm_sz) {
		case sizeof(flex_int32_t):
		    if (M4_YY_TABLES_VERIFY ){
			if ( ((flex_int32_t *) p)[0] != (flex_int32_t) t32)
			M4_YY_GLOBAL_FATAL_ERROR("tables verification failed at flex_int32_t");
		    }else
			((flex_int32_t *) p)[0] = (flex_int32_t) t32;
		    p = ((flex_int32_t *) p) + 1;
		    break;
		case sizeof(flex_int16_t):
		    if (M4_YY_TABLES_VERIFY ){
			if ( ((flex_int16_t *) p)[0] != (flex_int16_t) t32)
			M4_YY_GLOBAL_FATAL_ERROR("tables verification failed at flex_int16_t");
		    }else
			((flex_int16_t *) p)[0] = (flex_int16_t) t32;
		    p = ((flex_int16_t *) p) + 1;
		    break;
		case sizeof(flex_int8_t):
		    if (M4_YY_TABLES_VERIFY ){
			if ( ((flex_int8_t *) p)[0] != (flex_int8_t) t32)
			M4_YY_GLOBAL_FATAL_ERROR("tables verification failed at flex_int8_t");
		    }else
			((flex_int8_t *) p)[0] = (flex_int8_t) t32;
		    p = ((flex_int8_t *) p) + 1;
		    break;
		default:
		    M4_YY_GLOBAL_NONFATAL_ERROR("invalid dmap->dm_sz for plain int");
		    return -1;
		}
	    }
	}

    }

    /* Now eat padding. */
    {
	int pad;
	pad = yypad64(rd->bread);
	while (--pad >= 0){
	    flex_int8_t t8;
	    if (yytbl_read8(&t8,rd) != 0)
		return -1;
	}
    }

    return 0;
}

/* Find the key and load the DFA tables from the given stream.  */
M4_FUNC_DEF(static int, yytbl_fload, M4_INSTREAM * fp, const char * key)
{
    int rv=0;
    struct yytbl_hdr th;
    struct yytbl_reader rd;

    rd.fp = fp;
    th.th_version = NULL;

    /* Keep trying until we find the right set of tables or end of file. */
m4_if_cxx_streamio([[
    while (!rd.fp->eof()) {
]],[[
    while (!feof(rd.fp)) {
]])
	rd.bread = 0;
	if (yytbl_hdr_read(&th, &rd) != 0){
	    rv = -1;
	    goto return_rv;
	}

	/* A NULL key means choose the first set of tables. */
	if (key == NULL)
	    break;

	if (strcmp(th.th_name,key) != 0){
	    /* Skip ahead to next set */
m4_if_cxx_streamio([[
	    rd.fp->seekg(th.th_ssize - th.th_hsize, std::ios_base::cur);
]],[[
	    fseek(rd.fp, th.th_ssize - th.th_hsize, SEEK_CUR);
]])
	    yyfree(th.th_version);
	    th.th_version = NULL;
	}
	else
	    break;
    }

    while (rd.bread < th.th_ssize){
	/* Load the data tables */
	if (yytbl_data_load(yydmap,&rd) != 0){
	    rv = -1;
	    goto return_rv;
	}
    }

return_rv:
    if (th.th_version){
	yyfree(th.th_version);
	th.th_version = NULL;
    }

    return rv;
}

/** Load the DFA tables for this scanner from the given stream.  */
M4_FUNC_DEF(int, yytables_fload, M4_INSTREAM * fp)
{
    if ( yytbl_fload(fp, YYTABLES_NAME) != 0)
	return -1;
    return 0;
}

/** Destroy the loaded tables, freeing memory, etc.. */
M4_FUNC_DEF(int, yytables_destroy)
{
    struct yytbl_dmap *dmap=0;

    if (!M4_YY_TABLES_VERIFY){
	/* Walk the dmap, freeing the pointers */
	for(dmap=yydmap; dmap->dm_id; dmap++) {
	    void * v;
	    v = dmap->dm_arr;
	    if (v && *(char**)v){
		    yyfree(*(char**)v);
		    *(char**)v = NULL;
	    }
	}
    }

    return 0;
}
/* end table serialization code definitions */
]])m4_dnl endif tables_serialization

m4_dnl JMK: added table-loading and C++ iostream support to main.
m4_ifdef( [[M4_YY_MAIN]], [[
M4_FUNC_PROTO_NG(extern int, main);

M4_FUNC_DEF_NG(int, main)
{
    m4_if_reentrant([[
	yyscan_t yyscanner;
    ]])
    m4_if_cxx_only([[
	M4_YY_LEX_CLASS * lexer;
    ]])
    m4_if_tables_serialization([[
	m4_if_cxx_streamio([[
	std::ifstream *fp;
	fp = new std::ifstream("M4_YY_TABLES_FILENAME",ios::binary);
	if (!fp->is_open())
	]],
	[[
	FILE *fp;
	if (!(fp = fopen("M4_YY_TABLES_FILENAME","rb")))m4_dnl JMK: added binary flag.
	]])
	M4_YY_GLOBAL_FATAL_ERROR("could not open tables file \"M4_YY_TABLES_FILENAME\" for reading");

	if (yytables_fload(fp) < 0)
	M4_YY_GLOBAL_FATAL_ERROR("yytables_fload returned < 0");
    ]])
m4_dnl ######## NOTE: POSIX LEX MAIN() ONLY CALLS YYLEX() ONCE ############
    m4_if_cxx_only([[
	lexer = new m4_yy_class()();
	while(lexer->lex());
	delete lexer;
    ]],
    [[
	m4_if_reentrant([[
	yylex_init(&lexer);
	while (yylex(lexer));
	yylex_destroy( lexer);
	]],
	[[
	while(yylex());
	]])
    ]])
    m4_if_tables_serialization([[
	yytables_destroy();
    ]])
	return 0;
}
]])

