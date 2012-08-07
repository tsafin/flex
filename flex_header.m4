m4_divert(-1)
m4_changecom()
m4_changequote()
m4_changequote([[,]])
##########################################################################
# General-purpose m4 macros are defined here. Some are derived from m4sugar.m4

# m4_car(LIST)
# m4_cdr(LIST)
# ------------
# Manipulate m4 lists.
m4_define([[m4_car]], [[[[$1]]]])
m4_define([[m4_cdr]],
[[m4_ifelse([[$#]], 0, [[m4_fatal([[$0: cannot be called without arguments]])]],
       [[$#]], 1, [[]],
       [[m4_dquote(m4_shift($@))]])]])

# m4_foreach(VARIABLE, LIST, EXPRESSION)
# --------------------------------------
# Expand EXPRESSION assigning each value of the LIST to VARIABLE.
# LIST should have the form `item_1, item_2, ..., item_n', i.e. the
# whole list must *quoted*.  Quote members too if you don't want them
# to be expanded.
m4_define([[m4_foreach]],
[[m4_pushdef([[$1]])_m4_foreach($@)m4_popdef([[$1]])]])

m4_define([[_m4_foreach]],
[[m4_ifelse([[$2]],[[]],[[]],[[m4_define([[$1]], m4_car($2))$3[[]]m4_dnl
_m4_foreach([[$1]], m4_cdr($2), [[$3]])]])]])

# m4_echo(STRING)
# -------------------------
# Useful for unquoting a string.
m4_define([[m4_echo]],[[$*]])

# m4_quote(STRING)
# -------------------------
m4_define([[m4_quote]],[[[[$*]]]])

# m4_dquote(STRING)
# -------------------------
m4_define([[m4_dquote]],[[[[$@]]]])

# m4_shiftn(N, ...)
# -----------------
# Returns ... shifted N times.  Useful for recursive "varargs" constructs.
m4_define([[m4_shiftn]],m4_dnl
[[m4_ifelse([[$1]],0,[[m4_shift($@)]],[[m4_shiftn(m4_eval([[$1]]-1), m4_shift(m4_shift($@)))]])]])

# m4_bpatsubsts(STRING, RE1, SUBST1, RE2, SUBST2, ...)
# ----------------------------------------------------
# m4 equivalent of:
#   $_ = STRING;
#   s/RE1/SUBST1/g;
#   s/RE1/SUBST1/g;
#   s/RE2/SUBST2/g;
#   ...
m4_define([[m4_bpatsubsts]],
[[m4_ifelse([[$#]], 0, [[]],
       [[$#]], 1, [[$1]],
       [[$#]], 2, [[m4_builtin([[patsubst]], $@)]],
       [[$0(m4_builtin([[patsubst]], [[[[$1]]]], [[$2]], [[$3]]),
	   m4_shiftn(3, $@))]])]])

# m4_append(MACRO-NAME, STRING, [SEPARATOR])
# ------------------------------------------
# Append SEPARATORE and STRING to the end of the named macro.
# If the macro is undefined, SEPARATOR is not appended.
m4_define([[m4_append]],
[[m4_define([[$1]],
	   m4_ifdef([[$1]], [[m4_defn([[$1]])$3]])[[$2]])]])

# m4_appendl(MACRO-NAME, STRING)
# -----------------------------
# Append STRING and a newline char to the named macro.
m4_define([[m4_appendl]],
[[m4_define([[$1]],
	   m4_ifdef([[$1]], [[m4_defn([[$1]])]])[[$2[[
]]]])]])

# m4_bool(VALUE)
# --------------
# Try to convert VALUE to a boolean 0 or 1.
# If it looks like a macro, undefined is false, or defined with value 0.
# This assumes that macro names all start with M4_.
m4_define([[m4_bool]],
[[m4_ifelse(
    m4_regexp([[$1]],[[^M4_]]),0,m4_ifdef([[$1]],m4_ifelse([[$1]],0,0,1),0),
    [[$1]],0,0,
    [[$1]],[[false]],0,
    [[$1]],[[FALSE]],0,1)]])

# m4_if_elseif(BOOL1, IF-BOOL1, BOOL2, IF-BOOL2, ..., DEFAULT)
# -----------------------------------------------------------
# Make an if/then/elseif/.../endif construct with boolean conditions.
# Words starting with "M4_" are checked with ifdef.
m4_define([[m4_if_elseif]],
[[m4_ifelse(
    [[$#]], 0, [[]],
    [[$#]], 1, [[$1]],
    m4_bool([[$1]]), 1, [[$2]],
    [[$0(m4_shiftn(2,$@))]])
]])

# m4_if(BOOLEAN, IF-TRUE [, IF-FALSE])
# ------------------------------------
# A simple conditional with an evaluated condition expression.
m4_define([[m4_if]],[[m4_ifelse(m4_eval($1),1,[[$2]],[[$3]])]])

# m4_defined(MACRO-NAME)
# ----------------------
# return boolean 1 if the macro is defined, else 0.
m4_define([[m4_defined]],[[m4_ifdef([[$1]],[[1]],[[0]])]])

# m4_escape_backslash(STRING)
# ---------------------------
# Replace occurances of `\' with `\\'
m4_define([[m4_escape_backslash]],m4_dnl
[[m4_patsubst([[$*]],[[\\]],[[\\\\]])]])

# m4_escape_newline(MULTILINE-STRING)
# -----------------------------------
# Append backslashes to all newlines (i.e. to generate C macros).
# It also removes blank lines, and avoids a backslash on the last line.
m4_define([[m4_escape_newline]],[[m4_patsubst($*,[[[
	 ]*
\(.\)]],[[ [[\\]]
\1]])]])

# m4_flex_include(FILENAME)
# -------------------------
# m4 include() a file from the FLEX M4-INCLUDE directory.
m4_define([[m4_flex_include]],[[m4_include(M4_FLEX_INCLUDE()/$1)]])

# m4_print_string(MACRO_NAME)
# -----------------------------
# For debugging, print the quoted value of a macro, or `undefined'.
m4_define([[m4_print_string]],m4_dnl
[[/* [[$1]] = m4_ifdef([[$1]],"$1", undefined) */]])

# m4_print_value(MACRO_NAME)
# -----------------------------
# For debugging, print the un-quoted value of a macro, or `<undefined>'.
m4_define([[m4_print_string]],m4_dnl
[[/* [[$1]] = m4_ifdef([[$1]],$1, [[<undefined>]]) */]])

# m4_print_bool(MACRO_NAME)
# -------------------------
# For debugging, print a boolean m4 macro, where defined means TRUE. 
m4_define([[m4_print_bool]],m4_dnl
[[/* [[$1]] = m4_ifdef([[$1]],true,false) */]])

####################################################################
# This section defines functional M4 macros that replace the
# original simple conditionals processed in skelout(). Some of them are
# just syntactic sugar for ifdefs, but many are set by the choice of
# modes C, reentrant, or C++ class.

m4_ifdef( [[M4_YY_REENTRANT]],[[
    m4_define(m4_if_reentrant,$1)
    m4_define(m4_if_not_reentrant,$2)
]],[[
    m4_define(m4_if_reentrant,$2)
    m4_define(m4_if_not_reentrant,$1)
]])

m4_ifdef([[M4_YY_CPLUSPLUS]],[[
    m4_ifdef( [[M4_YY_CLASS]],,
    [[
	m4_ifdef( [[M4_YY_PREFIX]],
	[[
	    m4_define([[M4_YY_CLASS]],M4_YY_PREFIX()[[FlexLexer]])
	]],
	[[
	    m4_define([[M4_YY_CLASS]],[[yyFlexLexer]])
	]])
    ]])
    m4_define([[M4_YY_USE_MALLOC]],[[]])
    m4_define([[M4_YY_PREFIX]],[[]])
    m4_define([[M4_YY_LEX_BASE_CLASS]],[[FlexLexer[[$1]]]])
    m4_define([[M4_YY_LEX_CLASS]],[[M4_YY_CLASS[[$1]]]])
    m4_ifdef([[M4_YY_CXX_IOSTREAM]],,[[m4_define([[M4_YY_CXX_IOSTREAM]],1)]])
    m4_define([[m4_if_cxx_only]],[[$1]])
    m4_define([[m4_if_c_only]],[[$2]])
    m4_define([[m4_if_cxx_or_reentrant]],[[$1]])
    m4_define([[m4_if_cxx_or_not_reentrant]],[[$1]])
]],
[[
    m4_define([[M4_YY_LEX_CLASS]],[[]])
    m4_ifdef([[M4_YY_CXX_IOSTREAM]],,[[m4_define([[M4_YY_CXX_IOSTREAM]],0)]])
    m4_define([[m4_if_cxx_only]],[[$2]])
    m4_define([[m4_if_c_only]],[[$1]])
    m4_if_reentrant([[
	m4_define([[m4_if_cxx_or_reentrant]],[[$1]])
	m4_define([[m4_if_cxx_or_not_reentrant]],[[$2]])
    ]],[[
	m4_define([[m4_if_cxx_or_reentrant]],[[$2]])
	m4_define([[m4_if_cxx_or_not_reentrant]],[[$1]])
    ]])
]])

m4_ifelse(M4_YY_CXX_IOSTREAM,1,
[[
    m4_define([[m4_if_cxx_streamio]],[[$1]])
    m4_define([[M4_INSTREAM]],[[std::istream]])
    m4_define([[M4_OUTSTREAM]],[[std::ostream]])
    m4_define([[M4_STDIN]],[[&std::cin]])
    m4_define([[M4_STDOUT]],[[&std::cout]])
]],[[
    m4_define([[m4_if_cxx_streamio]],[[$2]])
    m4_define([[M4_INSTREAM]],[[FILE]])
    m4_define([[M4_OUTSTREAM]],[[FILE]])
    m4_define([[M4_STDIN]],[[stdin]])
    m4_define([[M4_STDOUT]],[[stdout]])
]])

m4_ifdef([[M4_YY_TABLES_EXTERNAL]],[[
    m4_define([[m4_if_tables_serialization]],[[$1]])
]],[[
    m4_define([[m4_if_tables_serialization]],[[$2]])
]])

####################################################################
# FIXME: should these be asserted in check_options()?
m4_if_not_reentrant([[
    m4_define([[M4_YY_NO_GET_EXTRA]],)
    m4_define([[M4_YY_NO_SET_EXTRA]],)
    m4_define([[M4_YY_NO_GET_LVAL]],)
    m4_define([[M4_YY_NO_SET_LVAL]],)
    m4_define([[M4_YY_NO_GET_LLOC]],)
    m4_define([[M4_YY_NO_SET_LLOC]],)
    m4_define([[M4_YY_NO_GET_COLUMN]])
    m4_define([[M4_YY_NO_SET_COLUMN]])
]],[[
    m4_ifdef([[M4_YY_BISON_LVAL]],,[[
	m4_ifdef([[M4_YY_NO_GET_LVAL]],,m4_define(M4_YY_NO_GET_LVAL,))
	m4_ifdef([[M4_YY_NO_SET_LVAL]],,m4_define(M4_YY_NO_SET_LVAL,))
    ]])
    m4_ifdef([[M4_YY_BISON_LLOC]],,[[
	m4_ifdef([[M4_YY_NO_GET_LLOC]],,m4_define(M4_YY_NO_GET_LLOC,))
	m4_ifdef([[M4_YY_NO_SET_LLOC]],,m4_define(M4_YY_NO_SET_LLOC,))
    ]])
]])

m4_if_c_only([[
    m4_ifdef([[M4_YY_STACK_USED]],,
    [[
	m4_define( [[M4_YY_NO_PUSH_STATE]])
	m4_define( [[M4_YY_NO_POP_STATE]])
	m4_define( [[M4_YY_NO_TOP_STATE]])
    ]])
]])
m4_if_cxx_or_reentrant([[
    m4_define([[M4_YY_STACK_USED]],1)
]])

m4_dnl C++ directly uses C-lib malloc.
m4_ifdef([[M4_YY_USE_MALLOC]],
[[
    m4_define([[M4_YY_NO_FLEX_ALLOC]])
    m4_define([[M4_YY_NO_FLEX_REALLOC]])
    m4_define([[M4_YY_NO_FLEX_FREE]])
    m4_define([[yyalloc]],[[malloc[[]]m4_ifelse($]][[#,0,,($]][[*))]])
    m4_define([[yyrealloc]],[[realloc[[]]m4_ifelse($]][[#,0,,($]][[*))]])
    m4_define([[yyfree]],[[free[[]]m4_ifelse($]][[#,0,,($]][[*))]])
]])

m4_ifdef([[M4_YY_ALWAYS_INTERACTIVE]],
[[
    m4_define([[M4_YY_NO_ISATTY]])
    m4_define([[M4_YY_NO_UNISTD_H]])
]])

m4_ifdef([[M4_YY_NEVER_INTERACTIVE]],
[[
    m4_define([[M4_YY_NO_ISATTY]])
    m4_define([[M4_YY_NO_UNISTD_H]])
]])

m4_ifdef([[M4_YY_TABLES_NAME]],,
[[
    m4_define([[M4_YY_TABLES_NAME]],[[yytables]])
]])

m4_if_cxx_only([[
    m4_undefine([[M4_YY_NO_UNPUT]])
]])

############################################################################
# Prefixes:
# These m4 macros rename functions and non-static variables.
# (Reentrant globals are renamed in a different place below.)
# The complexity here is necessary so that m4 preserves
# the argument lists to each C function, and still allow for
# references not followed by parenthesis.

m4_ifdef([[M4_YY_PREFIX]],,[[
    m4_define([[M4_YY_PREFIX]],[[yy]])
]])

m4_ifelse(M4_YY_PREFIX,[[]],[[
m4_define([[M4_YY_PREFIX_]],[[]])
]],[[
m4_define([[M4_YY_PREFIX_]],M4_YY_PREFIX()_)
]])

#--------------------------------------------------------------------
# For use in function documentation to adjust for additional argument.
m4_if_reentrant(
[[
m4_define( [[M4_YY_OBJECT_PARAM_DOC]], [[@param yyscanner The scanner object.]])
]],
[[
m4_define( [[M4_YY_OBJECT_PARAM_DOC]], [[]])
]])

############################################################################
# NOTE: These must be single-line definitions.
m4_if_reentrant([[
    m4_ifdef([[M4_YY_USE_LINENO]],[[
	m4_define([[M4_YY_USE_COLUMN]])
    ]])
]])

# XXX: These yycolumn macros assume that they are always preceded
# XXX: by a check for a '\n' character.
m4_ifdef([[M4_YY_USE_COLUMN]],
[[
    m4_define( [[M4_YY_INCR_LINENO]],
    [[{ yycolumn=0; ++yylineno; } else { ++yycolumn; }]])
    m4_define( [[M4_YY_DECR_LINENO]],
    [[{ yycolumn=0; --yylineno; } else { --yycolumn; }]])
]],
[[
    m4_define( [[M4_YY_INCR_LINENO]],
    [[[[yylineno]]=++yylineno]])
    m4_define( [[M4_YY_DECR_LINENO]],
    [[[[yylineno]]=--yylineno]])
]])

m4_dnl This NAMESPACE macro is only prtially implemented.
m4_ifdef([[M4_YY_NAMESPACE]],
[[
    m4_define([[m4_yynamespace]],[[M4_YY_NAMESPACE[[$1]]]])
]],[[
    m4_define([[m4_yynamespace]],[[]])
]])

# Same as m4_shift, but return 'void' if the result is empty.
m4_define([[m4_vshift]],[[m4_dnl
m4_ifelse([[$#]],0,[[void]],
	[[$#]],1,[[void]],
	[[m4_shift($@)]])]])

# m4_yy_prefix(NAME [, LINKAGE...] )
# ------------------------------
# Return a prefix-modified NAME, depending on whether LINKAGE...
# starts with 'static'
m4_define([[m4_yyprefix]],[[m4_dnl
m4_ifelse(m4_regexp([[$2]],[[^static]]),0,[[$1]],
m4_regexp([[$1]],[[^yy_]]),0,[[m4_patsubst([[$1]],[[^yy_]],M4_YY_PREFIX_())]],
m4_regexp([[$1]],[[^yy]]),0,[[m4_patsubst([[$1]],[[^yy]],M4_YY_PREFIX())]],
[[$1]])]])

# Functions names that match this pattern are marked as const in the
# C++ class scanner.
m4_define([[M4_CONST_REGEXP]],[[get_[a-z]* *$]])

###########################################################################
# M4_FUNC_PROTO(RETURN-TYPE, NAME, TYPE1 ARG1, TYPE2 ARG2, ...)
# -----------------------------------------------------------
# Declare the function NAME, create m4 conversion macros to add the extra
# argument for reentrant C scanners, and create a CPP #define to rename
# functions in user code. NOTE: the CPP macros do not add the reentrant
# yyscanner argument.
#
# These are rather dense to avoid adding extra space in the output,
# while trying to accomplish multiple tasks.

m4_define([[m4_rename_func]],[[m4_dnl
m4_ifelse(M4_YY_PREFIX(),[[yy]],[[]],m4_dnl
[[m4_appendl([[M4_CPP_RENAME_MACROS]],[[#define [[[[$1]]]] m4_yyprefix([[$1]])]])]])[[]]m4_dnl
]])m4_dnl

m4_dnl ==========================================================================
m4_if_c_only([[

m4_define([[M4_FUNC_DEF_NG]],[[m4_dnl
$1
m4_ifelse(m4_regexp([[$1]],[[^static]]),0,[[$2]],[[m4_yyprefix([[$2]])]])[[]]m4_dnl
(m4_vshift(m4_shift($@)))]])m4_dnl

m4_define([[M4_FUNC_PROTO_NG]],[[m4_dnl
m4_ifelse(m4_regexp([[$1]],[[^static]]),0,[[m4_dnl
$1 [[$2]](m4_vshift(m4_shift($@)))m4_dnl
]],[[m4_dnl
m4_rename_func($2)m4_dnl
$1 m4_yyprefix($2)(m4_vshift(m4_shift($@)))m4_dnl
m4_indir([[m4_define]],$2,m4_dquote(m4_yyprefix($2))[[m4_ifelse($]][[#,0,,($]][[*))]])[[]]m4_dnl
]])m4_dnl
]])m4_dnl

m4_dnl ==========================================================================
m4_if_reentrant([[

m4_define([[m4_yyscanner_arg]],[[m4_dnl
($@[[]]m4_ifelse(m4_regexp([[$1]],[[^ *$]]),[[-1]],[[, yyscanner]],[[yyscanner]]))]])

m4_define([[M4_FUNC_DEF]],[[m4_dnl
$1
m4_ifelse(m4_regexp([[$2]],M4_CONST_REGEXP),[[-1]],[[m4_dnl
[[$2]](m4_shiftn(2,$@,[[yyscan_t yyscanner]]))]],[[m4_dnl
[[$2]](m4_shiftn(2,$@,[[const yyscan_t yyscanner]]))]])m4_dnl
]])

m4_define([[M4_FUNC_PROTO]],[[m4_dnl
m4_ifelse(m4_regexp([[$1]],[[^static]]),0,[[m4_dnl
$1 $2]],[[m4_dnl
m4_rename_func($2)m4_dnl
$1 m4_yyprefix($2)]])[[]]m4_dnl
m4_dnl
m4_ifelse(m4_regexp([[$2]],M4_CONST_REGEXP),[[-1]],[[m4_dnl
(m4_shiftn(2,$@,[[yyscan_t yyscanner]]))]],[[m4_dnl
(m4_shiftn(2,$@,[[const yyscan_t yyscanner]]))]])m4_dnl
m4_dnl
m4_indir([[m4_define]],$2,m4_dquote(m4_yyprefix($2,$1))[[]]m4_dnl
 [[m4_ifelse($]][[#,0,,m4_yyscanner_arg($]][[*))]])]])m4_dnl

]],[[m4_dnl else non-reentrant
m4_dnl In the non-reentrant scanner, these are the same as for No-Globals versions
m4_define([[M4_FUNC_DEF]],[[m4_dnl
$1
[[$2]](m4_vshift(m4_shift($@)))]])[[]]m4_dnl
m4_define([[M4_FUNC_PROTO]],[[m4_dnl
m4_ifelse(m4_regexp([[$1]],[[^static]]),0,[[m4_dnl
$1 $2(m4_vshift(m4_shift($@)))m4_dnl
]],[[m4_dnl
m4_rename_func($2)m4_dnl
$1 m4_yyprefix($2)(m4_vshift(m4_shift($@)))m4_dnl
m4_indir([[m4_define]],$2,m4_dquote(m4_yyprefix($2))[[m4_ifelse($]][[#,0,,($]][[*))]])m4_dnl
]])m4_dnl
]])m4_dnl

]]) endif reentrant

m4_dnl ==========================================================================
]],[[m4_dnl else C++

m4_define([[M4_FUNC_DEF_NG]],[[m4_dnl
m4_bpatsubsts([[$1]],[[\bstatic *]],[[]],[[\b\(YY\|yy\)]],[[M4_YY_CLASS::\1]])
M4_YY_CLASS::m4_yystrip([[$2]])(m4_vshift(m4_shift($@)))]])

m4_define([[M4_FUNC_DEF]],[[m4_dnl
m4_bpatsubsts([[$1]],[[\bstatic *]],[[]],[[\b\(YY\|yy\)]],[[M4_YY_CLASS::\1]])
M4_YY_CLASS::m4_yystrip([[$2]])(m4_vshift(m4_shift($@)))m4_dnl
m4_ifelse(m4_regexp([[$2]],M4_CONST_REGEXP),[[-1]],[[]],[[ const]])]])

m4_define([[M4_FUNC_PROTO_NG]],[[m4_dnl
m4_ifelse(m4_regexp([[$2]],[[^yy\(in\|un\|out\)put *$]]),0,,[[m4_rename_func($2)]])m4_dnl
m4_ifelse(m4_regexp([[$1]],[[^static]]),0,[[protected: ]],[[public: ]])m4_dnl
static m4_patsubst([[$1]],[[^\(static\|extern\) ]]) m4_yystrip($2)(m4_vshift(m4_shift($@)))m4_dnl
]])m4_dnl

m4_define([[M4_FUNC_PROTO]],[[m4_dnl
m4_ifelse(m4_regexp([[$2]],[[^yy\(in\|un\|out\)put *$]]),0,,[[m4_rename_func($2)]])m4_dnl
m4_ifelse(m4_regexp([[$1]],[[^static]]),0,[[protected: ]],[[public: ]])m4_dnl
m4_patsubst([[$1]],[[^\(static\|extern\) ]]) m4_yystrip($2)(m4_vshift(m4_shift($@)))m4_dnl
m4_ifelse(m4_regexp([[$2]],M4_CONST_REGEXP),[[-1]],[[]],[[ const]])]])m4_dnl

]])
m4_dnl ==========================================================================

m4_define([[m4_yystrip]],[[m4_ifelse(
    m4_regexp([[$1]],[[^yy\(in\|un\|out\)put *$]]),0,[[$1]],
    m4_patsubst([[$1]],[[^yy_?]]))]])

# Return a "clean" value from the named macro.
# Cleaning means to remove blank lines and trailing spaces.
m4_define([[m4_clean]],[[m4_patsubst(m4_defn([[$1]]),[[ *
\([ 	]*
\)*]],[[
]])]])

# Re-define the named macro to contain cleaned text, as defined above.
m4_define([[m4_clean_def]],[[
m4_indir([[m4_define]],[[$1]],m4_clean([[$1]]))
]])

###########################################################################
## The line number will be replaced by the output filter. The m4 source
## line is inserted for now as a possible aid to debugging this m4 script.
m4_ifdef([[M4_YY_NO_LINE]],[[
m4_define([[M4_LINE_DIRECTIVE]],[[]])
]],
[[
m4_define([[M4_LINE_DIRECTIVE]],[[#line m4___line__ "M4_YY_OUTFILE_NAME"]])
]])

###########################################################################
# Build table definitions, and also declarations if C++.

# NOTE: yy_start_state_list[] is a list of indices into yy_transition[],
# stored as pointers to yy_transition[] elements.
m4_ifdef([[M4_YY_START_STATE_LIST_TABLE_DATA]],[[
m4_define([[M4_YY_START_STATE_LIST_TABLE_DATA_REF]],[[m4_dnl
m4_foreach([[INDEX]],m4_dquote(M4_YY_START_STATE_LIST_TABLE_DATA),[[
    &yy_transition[INDEX],]])
]])
m4_define([[M4_YY_START_STATE_LIST_TABLE_DATA]],
m4_quote(M4_YY_START_STATE_LIST_TABLE_DATA_REF))
]])

m4_if_tables_serialization([[
m4_define([[m4_data_table]],[[m4_ifdef([[M4_$1_TABLE_SIZE]],[[
m4_appendl([[M4_YY_DMAP_TABLE]],
[[	{m4_patsubst([[$1]],[[^YY_]],[[YYTD_ID_]]), (void**)m4_dnl
 &m4_translit([[$1]],[[A-Z]],[[a-z]]),m4_dnl
 sizeof(*(m4_translit([[$1]],[[A-Z]],[[a-z]])))},]])
static const $2 m4_if(M4_YY_TABLES_VERIFY,
[[m4_translit([[$1]],[[A-Z]],[[a-z]])[M4_$1_TABLE_SIZE] = { M4_$1_TABLE_DATA };]],
[[* m4_translit([[$1]],[[A-Z]],[[a-z]]) = 0;]])m4_dnl
]])]])

m4_define([[m4_int_table]],
[[m4_data_table($1,m4_ifdef(M4_$1_TABLE_32BIT,[[flex_int32_t]],[[flex_int16_t]]))]])

]],[[

m4_define([[m4_data_table]],[[m4_ifdef([[M4_$1_TABLE_DATA]],[[
static const $2 m4_translit([[$1]],[[A-Z]],[[a-z]])[M4_$1_TABLE_SIZE] = [[{ M4_$1_TABLE_DATA }]];
]])]])

m4_define([[m4_int_table]],
[[m4_data_table($1,m4_ifdef(M4_$1_TABLE_32BIT,[[flex_int32_t]],[[flex_int16_t]]))]])
]])
m4_define([[M4_GEN_DATA_TABLES]],[[
m4_int_table(YY_ACCLIST)
m4_int_table(YY_ACCEPT)
m4_int_table(YY_BASE)
m4_int_table(YY_CHK)
m4_int_table(YY_DEF)
m4_int_table(YY_EC)
m4_int_table(YY_META)
m4_int_table(YY_NUL_TRANS)
m4_int_table(YY_NXT)
m4_int_table(YY_RULE_CAN_MATCH_EOL)
m4_data_table(YY_TRANSITION,[[struct yy_trans_info]])
m4_data_table(YY_START_STATE_LIST,[[struct yy_trans_info*]])

m4_ifdef([[M4_YY_DMAP_TABLE]],[[
/** A {0,0,0}-terminated list of structs, forming the map */
static struct yytbl_dmap yydmap[] = {
M4_YY_DMAP_TABLE()m4_dnl
	{YYTD_ID_END,0,0}
};]])

m4_dnl The rule_linenum table is never serialized.
m4_dnl It is mainly for debugging, and also normally small.
m4_ifdef([[M4_YY_RULE_LINENUM_TABLE_DATA]],[[
static const m4_ifdef(M4_YY_RULE_LINENUM_TABLE_32BIT,[[flex_int32_t]],[[flex_int16_t]]) m4_dnl
yy_rule_linenum[M4_YY_RULE_LINENUM_TABLE_SIZE] = {M4_YY_RULE_LINENUM_TABLE_DATA};
]])
]])
######################################################################
