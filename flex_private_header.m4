m4_dnl Private typedefs and function declarations,
m4_dnl where "private" means file-scope; i.e. static C functions.

m4_ifdef( [[M4_YY_NO_UNISTD_H]],,
[[
#ifndef YY_NO_UNISTD_H
/* Special case for "unistd.h", since it is non-ANSI. */
#  include <unistd.h>
#else
#  ifdef __cplusplus
extern "C" {
    extern int isatty(int, fd);
}
#  else
extern int isatty(int, fd);
#  endif
#endif
]])

#ifndef YY_
#  ifdef YYENABLE_NLS
#    include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#    define YY_(msgid) dgettext ("flex-runtime", msgid)
#  else
#    define YY_(msgid) msgid
#  endif
#endif

/************************************************************/
/* Private (file scope) CPP definitions */

m4_if_tables_serialization([[
/* The name for this specific scanner's tables. */
#define YYTABLES_NAME "M4_YY_TABLES_NAME"
]])

m4_ifdef( [[M4_YY_VARIABLE_TRAILING_CONTEXT_RULES]],
[[
#define YY_TRAILING_MASK M4_YY_TRAILING_MASK;
#define YY_TRAILING_HEAD_MASK M4_YY_TRAILING_HEAD_MASK;
]])

m4_ifdef( [[M4_YY_SKIP_YYWRAP]],
    [[
#define YY_SKIP_YYWRAP
m4_dnl C++ uses an inline yywrap constant function instead of a macro
    m4_if_c_only([[
#define yywrap() 1
    ]])
]])

m4_ifdef( [[M4_FLEX_DEBUG]],
[[
#define FLEX_DEBUG
]])

m4_if_reentrant([[
#define YY_REENTRANT 1
]])

m4_ifdef( [[M4_YY_TEXT_IS_ARRAY]],,
[[
#define yytext_ptr yytext
]])

#define YY_BUFFER_NEW 0
#define YY_BUFFER_NORMAL 1
	/* When an EOF's been seen but there's still some text to process
	 * then we mark the buffer as YY_EOF_PENDING, to indicate that we
	 * shouldn't try reading from the input source any more.  We might
	 * still have a bunch of tokens to match, though, because of
	 * possible backing-up.
	 *
	 * When we actually see the EOF, we change the status to "new"
	 * (via yyrestart), so that the user can continue scanning by
	 * just pointing yyin at a new input file.
	 */
#define YY_BUFFER_EOF_PENDING 2

/* Returned upon end-of-file. */
#define YY_NULL 0

#define YY_JAMBASE M4_YY_JAMBASE
#define YY_JAMSTATE M4_YY_JAMSTATE
#define YY_LASTDFA M4_YY_LASTDFA
#define YY_NUL_EC M4_YY_NUL_EC

/* These are bit-flags for yy_init */
#define YYLEX_INIT_STATE 1
#define YYLEX_INIT_USER 2

#define YY_NUM_RULES M4_YY_NUM_RULES
#define YY_END_OF_BUFFER m4_eval(M4_YY_NUM_RULES+1)

/* Promotes a possibly negative, possibly signed char to an unsigned
 * integer for use as an array index.  If the signed char is negative,
 * we want to instead treat it as an 8-bit unsigned char, hence the
 * double cast.
 */
#define YY_SC_TO_UI(c) ((unsigned int) (unsigned char) c)

/* Enter a start condition.  This macro really ought to take a parameter,
 * but we do it the disgusting crufty way forced on us by the()-less
 * definition of BEGIN.
 */
#define BEGIN yy_start = 1 + 2 *

/* Translate the current start state into a value that can be later handed
 * to BEGIN to return to the state.  The YYSTATE alias is for lex
 * compatibility.
 */
#define YY_START ((yy_start - 1) / 2)
#define YYSTATE YY_START

/* Action number for EOF rule of a given start state. */
#define YY_STATE_EOF(state) (YY_END_OF_BUFFER + state + 1)

/* Special action meaning "start processing a new file". */
#define YY_NEW_FILE yyrestart( yyin )

#define YY_END_OF_BUFFER_CHAR 0

/* The state buf must be large enough to hold one state per character in the main buffer.
 */
#define YY_STATE_BUF_SIZE   ((YY_BUF_SIZE + 2) * sizeof(yy_state_type))

#define EOB_ACT_CONTINUE_SCAN 0
#define EOB_ACT_END_OF_FILE 1
#define EOB_ACT_LAST_MATCH 2

m4_ifdef( [[M4_YY_USE_LINENO]],
[[
/* Note: We specifically omit the test for yy_rule_can_match_eol because it requires
 *       access to the local variable yy_act. Since yyless() is a macro, it would break
 *       existing scanners that call yyless() from OUTSIDE yylex. 
 *       One obvious solution it to make yy_act a global. I tried that, and saw
 *       a 5% performance hit in a non-yylineno scanner, because yy_act is
 *       normally declared as a register variable-- so it is not worth it.
 */
#define  YY_LESS_LINENO(n) \
	do { \
	    int yyl; \
	    for( yyl = n; yyl < yyleng; ++yyl ) \
		if ( yytext[[yyl]] == '\n' ) \
		    M4_YY_DECR_LINENO; \
	} while (0)
]],
[[
#define YY_LESS_LINENO(n)
]])

/* Return all but the first "n" matched characters back to the input stream. */
#define yyless(n) \
	do \
		{ \
		/* Undo effects of setting up yytext. */ \
	int yyless_macro_arg = (n); \
	YY_LESS_LINENO(yyless_macro_arg); \
		*yy_cp = yy_hold_char; \
		YY_RESTORE_YY_MORE_OFFSET \
		yy_c_buf_p = yy_cp = yy_bp + yyless_macro_arg - YY_MORE_ADJ; \
		YY_DO_BEFORE_ACTION; /* set up yytext again */ \
		} \
	while ( 0 )

m4_if_c_only([[
    m4_ifdef( [[M4_YY_NO_UNPUT]],,[[m4_dnl
m4_dnl m4 macros will insert the yyscanner arg to yyinputi here, if needed.
#define unput(c) yyunput( c, yytext_ptr )
    ]])
]])

#ifndef YY_NO_INPUT
m4_if_reentrant([[m4_dnl
#define input() yyinput(yyscanner)
]],m4_dnl
[[m4_dnl
#define input() yyinput()
]])m4_dnl
#endif

/* We provide macros for accessing buffer states in case in the
 * future we want to put the buffer states in a more general
 * "scanner state".
 *
 * Returns the top of the stack, or NULL.
 */
#define YY_CURRENT_BUFFER ( yy_buffer_stack \
			  ? yy_buffer_stack[yy_buffer_stack_top] \
			  : NULL )

/* Same as previous macro, but useful when we know that the buffer stack is not
 * NULL or when we need an lvalue. For internal use only.
 */
#define YY_CURRENT_BUFFER_LVALUE yy_buffer_stack[yy_buffer_stack_top]

m4_if_c_only([[

#define YY_FLUSH_BUFFER yy_flush_buffer( YY_CURRENT_BUFFER)

#define yy_new_buffer yy_create_buffer

#define yy_set_interactive(is_interactive_) \
	{ \
	if ( ! YY_CURRENT_BUFFER ){ \
	yyensure_buffer_stack(); \
		YY_CURRENT_BUFFER_LVALUE =    \
	    yy_create_buffer( yyin, YY_BUF_SIZE); \
	} \
	YY_CURRENT_BUFFER->is_interactive = is_interactive_; \
	}

#define yy_set_bol(at_bol_) \
	{ \
	if ( ! YY_CURRENT_BUFFER ){ \
	yyensure_buffer_stack(); \
		YY_CURRENT_BUFFER_LVALUE =    \
	    yy_create_buffer( yyin, YY_BUF_SIZE); \
	} \
	YY_CURRENT_BUFFER->at_bol = at_bol_; \
	}

#define YY_AT_BOL() (YY_CURRENT_BUFFER->at_bol)

]])

/* Done after the current pattern has been matched and before the
 * corresponding action - sets up yytext.
YY_TEXT_IS_ARRAY = m4_ifdef([[M4_YY_TEXT_IS_ARRAY]],[[true]],[[false]])
YY_USES_YYMORE = m4_ifdef([[M4_YY_USES_YYMORE]],[[true]],[[false]])
 */
m4_dnl Define YY_DO_BEFORE_ACTION, depending on yytext and yymore usage.
m4_dnl This is converted to macro format with backslash line continuations
m4_dnl after it is defined to avoid errors in M4 processing, and to allow
m4_dnl the same code to be as a non-macro function body in the C++ code.
m4_dnl
m4_define([[M4_YY_DO_BEFORE_ACTION]],
[[
	yytext_ptr = yy_bp;
m4_dnl %% [2.0] code to fiddle yytext and yyleng for yymore() goes here
  m4_if(m4_defined([[M4_YY_USES_YYMORE]]) && !m4_defined([[M4_YY_TEXT_IS_ARRAY]]),
  [[
	yytext_ptr -= yy_more_len;
	yyleng = (size_t) (yy_cp - yytext_ptr);
  ]],
  [[
	yyleng = (size_t) (yy_cp - yy_bp);
  ]])
	yy_hold_char = *yy_cp;
	*yy_cp = '\0';
m4_dnl %% [3.0] code to copy yytext_ptr to yytext[] goes here, if %array
  m4_ifdef( [[M4_YY_TEXT_IS_ARRAY]],
  [[
    m4_ifdef( [[M4_YY_USES_YYMORE]],
    [[
	if ( yyleng + yy_more_offset >= YYLMAX )
		YY_FATAL_ERROR("token too large, exceeds YYLMAX");
	yy_flex_strncpy( &yytext[yy_more_offset], yytext_ptr, yyleng + 1);
	yyleng += yy_more_offset;
	yy_prev_more_offset = yy_more_offset;
	yy_more_offset = 0;

    ]],
    [[
	if ( yyleng >= YYLMAX )
		YY_FATAL_ERROR("token too large, exceeds YYLMAX");
	yy_flex_strncpy( yytext, yytext_ptr, yyleng + 1);
    ]])
  ]])
	yy_c_buf_p = yy_cp;
]])

#define YY_DO_BEFORE_ACTION \
m4_escape_newline(M4_YY_DO_BEFORE_ACTION)

m4_ifdef( [[M4_YY_USES_REJECT]],
[[
#define REJECT \
{ \
	*yy_cp = yy_hold_char; /* undo effects of setting up yytext */ \
	yy_cp = yy_full_match; /* restore poss. backed-over text */ \
m4_ifdef( [[M4_YY_variable_trailing_context_rules]],[[m4_dnl \
	yy_lp = yy_full_lp; /* restore orig. accepting pos. */ \
	yy_state_ptr = yy_full_state; /* restore orig. state */ \
	yy_current_state = *yy_state_ptr; /* restore curr. state */ \
]])m4_dnl \
	++yy_lp; \
	goto find_rule; \
}
]],
[[
/* The intent behind this definition is that it'll catch
 * any uses of REJECT which flex missed.
 */
#define REJECT reject_used_but_not_detected
]])

m4_ifdef( [[M4_YY_USES_YYMORE]],
[[
    m4_ifdef( [[M4_YY_TEXT_IS_ARRAY]],
    [[
#define yymore() (yy_more_offset = yy_flex_strlen(yytext))
#define YY_NEED_STRLEN
#define YY_MORE_ADJ 0
#define YY_RESTORE_YY_MORE_OFFSET \
	{ \
		yy_more_offset = yy_prev_more_offset; \
		yyleng -= yy_more_offset; \
	}
    ]],
    [[
#define yymore() (yy_more_flag = 1)
#define YY_MORE_ADJ yy_more_len
#define YY_RESTORE_YY_MORE_OFFSET
    ]])
]],
[[
/* The intent behind this definition is that it'll catch
 * any uses of yymore() which flex missed.
 */
#define yymore() yymore_used_but_not_detected
#define YY_MORE_ADJ 0
#define YY_RESTORE_YY_MORE_OFFSET
]])

#ifndef YY_START_CONDITIONS_DEFINED
M4_YY_SC_DEFS
#endif

/************************************************************/
m4_if_reentrant([[m4_dnl
/* Prefix conversion and reentrant-struct access macros, for user code. */
]],[[m4_dnl
/* Prefix conversion macros, for user code. */
]])
#ifndef YY_NO_RENAME_MACROS
m4_if_cxx_only([[#define yylex lex]])
m4_dnl remove `[YYLMAX]' from `yytext[YYLMAX]' and remove #defines for yylval,yylloc
m4_patsubst(m4_dquote(m4_patsubst(M4_CPP_RENAME_MACROS,\[YYLMAX\])),[[#define yyl\(val\|loc\) .*]])
m4_ifelse(M4_YY_PREFIX,[[yy]],,[[
/* These have renamed prefixes in previous flex versions. All other
 * static functions retain the yy prefix, so these were changed to conform.
 */
#define M4_YY_PREFIX()_init_buffer yy_init_buffer
#define M4_YY_PREFIX()_load_buffer_state yy_load_buffer_state
]])
#endif /* YY_NO_RENAME_MACROS */
m4_if_reentrant([[
/* FIXME: why are these mapped to a specific buffer only for the reentrant scanner?? */
#undef yylineno
#define yylineno  (YY_CURRENT_BUFFER->bs_lineno)
#define yycolumn  (YY_CURRENT_BUFFER->bs_column)
]])

