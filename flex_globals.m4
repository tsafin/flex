# This file creates two lists of globals as M4 macros:
# M4_PUBLIC_GLOBALS: These are part of the API and are user-accessible.
# M4_PRIVATE_GLOBALS: These are for internal use, and static in the non-reentran C scanner.

# M4_GLOBAL(LINKAGE TYPE, NAME, INIT_VAL)
# ---------------------------------------

m4_if_reentrant([[
    m4_define([[M4_GLOBAL]],[[

	m4_appendl([[M4_CPP_RENAME_MACROS]],
	[[[[#define [[$2]] (((struct yyobject_t*)yyscanner)->m4_yystrip([[$2]]))]]]])

	m4_appendl([[M4_M4_RENAME_MACROS]],
	[[[[m4_define([[$2]],m4_dquote([[(((struct yyobject_t*)yyscanner)->]]m4_yystrip([[$2]])[[)]]))]]]])

	m4_ifelse([[$#]],3,[[
	    m4_appendl([[M4_GLOBALS_INIT]],
	    [[    ((struct yyobject_t*)yyscanner)->m4_patsubst([[$2]],[[^yy_?]]) = $3;]])
	]])

    m4_patsubst([[$1]],[[^\(static\|extern\) *]]) m4_patsubst([[$2]],[[^yy_?]]);]])
]],
[[
    m4_if_c_only([[
	m4_define([[M4_GLOBAL]],[[

	    m4_ifelse([[M4_YY_PREFIX]],[[yy]],,[[
		m4_appendl([[M4_CPP_RENAME_MACROS]],[[[[#define [[$2]] m4_yyprefix([[$2]])]]]])
		m4_appendl([[M4_M4_RENAME_MACROS]],[[[[m4_define([[$2]],m4_dquote(m4_yyprefix([[$2]])))]]]])
	    ]])

	    m4_ifelse([[$#]],3,[[
		m4_appendl([[M4_GLOBALS_INIT]],
		[[    m4_yyprefix([[$2]],[[$1]]) = $3;]])
		m4_appendl([[M4_GLOBALS_DEF]],
		[[m4_patsubst([[$1]],[[^extern *]]) m4_yyprefix([[$2]],[[$1]]) = $3;]])
	    ]],
	    [[
		m4_appendl([[M4_GLOBALS_DEF]],
		[[m4_patsubst([[$1]],[[^extern *]]) m4_yyprefix([[$2]],[[$1]]);]])
	    ]])

$1 m4_yyprefix([[$2]],[[$1]]);]])
    ]],
    [[
	m4_define([[M4_GLOBAL]],[[

	    m4_appendl([[M4_CPP_RENAME_MACROS]],
	    [[#define [[$2]] m4_patsubst([[$2]],[[^yy_?]])]])

	    m4_appendl([[M4_M4_RENAME_MACROS]],
	    [[[[m4_define([[$2]],[[m4_patsubst([[$2]],[[^yy_?]])]])]]]])

	    m4_ifelse([[$#]],3,[[
		m4_appendl([[M4_GLOBALS_INIT]],
		[[    m4_patsubst([[$2]],[[^yy_?]]) = $3;]])
	    ]])

	m4_patsubst([[$1]],[[^\(static\|extern\) *]]) m4_patsubst([[$2]],[[^yy_?]]);]])
    ]])
]])

m4_dnl :: M4_GLOBAL(linkage+type, name, initval)
m4_dnl These are unquoted, because we want the rename macros evaluated now.

m4_define([[M4_PUBLIC_GLOBALS]],
    m4_if_reentrant([[
	m4_ifdef( [[M4_YY_NO_EXTRA]],,
	[[
	/* User-defined. Not touched by flex. */
	/* Defined first so that (yyobject_t*) can be cast to (YY_EXTRA_TYPE*) */
M4_GLOBAL(extern YY_EXTRA_TYPE, yyextra)
	]])
    ]])
M4_GLOBAL(extern M4_INSTREAM *, yyin, YYIN_INIT)
M4_GLOBAL(extern M4_OUTSTREAM *, yyout, YYOUT_INIT)
    m4_ifdef( [[M4_YY_TEXT_IS_ARRAY]],[[
M4_GLOBAL(extern char, yytext[YYLMAX])
    ]],[[
M4_GLOBAL(extern char *, yytext, NULL)
    ]])
    m4_if_not_reentrant([[
m4_dnl /* NOTE: The reentrant scanner uses (YY_CURRENT_BUFFER->bs_lineno) */
m4_dnl /* We do not touch yylineno unless the option is enabled. */
m4_dnl If not enabled, it is still supplied for user's line tracking.
        m4_ifdef( [[M4_YY_USE_LINENO]],[[
M4_GLOBAL(extern int, yylineno, 1)
        ]],[[
M4_GLOBAL(extern int, yylineno)
        ]])
    ]])
M4_GLOBAL(extern int, yy_flex_debug, m4_ifdef([[M4_FLEX_DEBUG]],1,0))
M4_GLOBAL(extern int, yyleng, 0)
)m4_dnl

m4_define([[M4_PRIVATE_GLOBALS]],
    /* Private globals */

/* Stack of input buffers. */
M4_GLOBAL(static size_t, yy_buffer_stack_top, 0) /**< index of top of stack. */
M4_GLOBAL(static size_t, yy_buffer_stack_max, 0) /**< capacity of stack. */
M4_GLOBAL(static YY_BUFFER_STATE *, yy_buffer_stack, 0) /**< Stack as an array. */

/* yy_hold_char holds the character lost when yytext is formed. */
M4_GLOBAL(static char, yy_hold_char)
M4_GLOBAL(static int, yy_n_chars)

/* Points to current character in buffer. */
M4_GLOBAL(static char *, yy_c_buf_p, 0)

/* Flag indicating whether the yylex state is intialized; called from yylex */
M4_GLOBAL(static int, yy_init, 0)

/* Defines the initial start state for current start-condition */
M4_GLOBAL(static int, yy_start, 0)

/* Flag which is used to allow yywrap()'s to do buffer switches
 * instead of setting up a fresh yyin.  A bit of a hack ...
 */
M4_GLOBAL(static int, yy_did_buffer_switch_on_eof, 0)

    m4_ifdef( [[M4_YY_STACK_USED]],
    [[
/* Stack state */
M4_GLOBAL(static int, yy_start_stack_ptr, 0)
M4_GLOBAL(static int, yy_start_stack_depth, 0)
M4_GLOBAL(static int *, yy_start_stack, 0)
    ]])

    m4_ifdef( [[M4_YY_NEED_BACKING_UP]],
    [[
/* Definitions for backing up.  We don't need them if REJECT
 * is being used because then we use an alternative backing-up
 * technique instead.
 */
M4_GLOBAL(static yy_state_type, yy_last_accepting_state)
M4_GLOBAL(static char *, yy_last_accepting_cpos)
    ]])

    m4_ifdef( [[M4_YY_USES_REJECT]],
    [[
/* Reject state buffer variables */
M4_GLOBAL(static yy_state_type *, yy_state_buf, 0)
M4_GLOBAL(static yy_state_type *, yy_state_ptr, 0)
M4_GLOBAL(static char *, yy_full_match)
M4_GLOBAL(static int, yy_lp)
    ]])

    m4_ifdef( [[M4_YY_VARIABLE_TRAILING_CONTEXT_RULES]],
    [[
    /* trailing-context state information */
M4_GLOBAL(static int, yy_looking_for_trail_begin, 0)
M4_GLOBAL(static int, yy_full_lp)
M4_GLOBAL(static int *, yy_full_state)
    ]])

    /* yytext state information */
    m4_ifdef( [[M4_YY_TEXT_IS_ARRAY]],
    [[
M4_GLOBAL(static char *, yytext_ptr, NULL)
    ]])
    m4_ifdef( [[M4_YY_USES_YYMORE]],
    [[
	m4_ifdef( [[M4_YY_TEXT_IS_ARRAY]],
	[[
M4_GLOBAL(static int, yy_more_offset, 0)
M4_GLOBAL(static int, yy_prev_more_offset, 0)
	]],
	[[
M4_GLOBAL(static int, yy_more_flag, 0)
M4_GLOBAL(static int, yy_more_len, 0)
	]])
    ]])

    m4_if_cxx_or_reentrant([[
	m4_ifdef( [[M4_YY_BISON_LVAL]],
	[[
M4_GLOBAL(static YYSTYPE *, yylval)
	]])

	m4_ifdef( [[M4_YY_BISON_LLOC]],
	[[
M4_GLOBAL(static YYLTYPE *, yylloc)
	]])
    ]])
)m4_dnl end M4_PRIVATE_GLOBALS

m4_clean_def([[M4_PUBLIC_GLOBALS]])
m4_clean_def([[M4_PRIVATE_GLOBALS]])

