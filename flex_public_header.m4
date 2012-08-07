/************************************************************/
/* Public CPP definitions */
/* FIXME: Some of this file should be in the private header section. */

#define YY_INT_ALIGNED M4_YY_INT_ALIGNED()

m4_ifdef( [[M4_YY_DO_STDINIT]],
[[
/* yyin and yyout are always set to stdin and stdout if NULL during the
 * first call to yylex(). Ths STDINIT feature only determines if they
 * should be initialized to stdio at compile time.
 */
#ifdef VMS
#  ifndef __VMS_POSIX
#    undef YY_STDINIT
#  endif
#endif

#ifdef YY_STDINIT
#define YYIN_INIT M4_STDIN;
#define YYOUT_INIT M4_STDOUT;
#else
#define YYIN_INIT ((M4_INSTREAM *)0)
#define YYOUT_INIT ((M4_OUTSTREAM *)0)
#endif
]],
[[
#define YYIN_INIT ((M4_INSTREAM *)0)
#define YYOUT_INIT ((M4_OUTSTREAM *)0)
]])

#define FLEX_SCANNER
m4_define(m4_define_version_,[[
#define YY_FLEX_MAJOR_VERSION $1
#define YY_FLEX_MINOR_VERSION $2
#define YY_FLEX_SUBMINOR_VERSION $3
]])
#define YY_FLEX_VERSION M4_FLEX_VERSION()
m4_define_version_(m4_patsubst(M4_FLEX_VERSION(),[[\.]],[[,]]))
#if YY_FLEX_SUBMINOR_VERSION > 0
#define FLEX_BETA
#endif

m4_ifdef( [[M4_YY_IN_HEADER]],
[[
#ifdef YY_HEADER_EXPORT_START_CONDITIONS
#define YY_START_CONDITIONS_DEFINED
M4_YY_SC_DEFS
#endif]])

m4_ifdef( [[M4_YY_FLEX_LEX_COMPAT]],
[[
#define YY_FLEX_LEX_COMPAT
]])

m4_ifdef( [[M4_EXTRA_TYPE_DEF]],
[[
#define YY_EXTRA_TYPE M4_EXTRA_TYPE_DEF
]])

/* Size of default input buffer. */
#ifndef YY_BUF_SIZE
#define YY_BUF_SIZE 16384
#endif

m4_ifdef( [[M4_YY_TEXT_IS_ARRAY]],
[[
#ifndef YYLMAX
#define YYLMAX 8192
#endif
]])

m4_ifdef( [[M4_EXTRA_TYPE_DEF]],,
[[
#ifndef YY_EXTRA_TYPE
#define YY_EXTRA_TYPE void *
#endif
]])

/* Amount of stuff to slurp up with each read. */
#ifndef YY_READ_BUF_SIZE
#define YY_READ_BUF_SIZE 8192
#endif

/* Number of entries by which start-condition stack grows. */
#ifndef YY_START_STACK_INCR
#define YY_START_STACK_INCR 25
#endif

/* FIXME: move these to the private header? */
/* Copy whatever the last rule matched to the standard output. */
#ifndef ECHO
m4_if_c_only([[
/* This used to be an fputs(), but since the string might contain NUL's,
 * we now use fwrite(). Checking for successful output is new.
 */
#define ECHO if ( fwrite(yytext, 1, yyleng, yyout) != yyleng) \
		{ YY_FATAL_ERROR("output in flex scanner failed"); }
]],
[[
#define ECHO if ( LexerOutput( yytext, yyleng) != yyleng) \
		{ YY_FATAL_ERROR("output in flex scanner failed"); }
]])
#endif

m4_ifdef([[M4_YY_OUTPUT]],
[[
/* NOTE: Flex does not use this macro. Redefining it will not
 * redirect output.
 */
    m4_if_cxx_streamio([[
#define output(c) yyout->put(c)
    ]],
    [[
#define output(c) fputc(c,yyout)
    ]])
]])

/* YY_INPUT Gets input and stuffs it into "buf".  number of characters read, or YY_NULL,
 * is returned in "result".
 */
#ifndef YY_INPUT
m4_if_cxx_only(
[[
#define YY_INPUT(buf,result,max_size) \
	if ( (result = LexerInput( (char *) buf, max_size )) < 0 ) \
		YY_FATAL_ERROR("input in flex scanner failed");
]],
[[
m4_dnl M4_YY_INPUT is defined in flex_code_macros.m4
#define YY_INPUT(buf,result,max_size) \
m4_escape_newline(M4_YY_INPUT)
]])
#endif

/* No semi-colon after return; correct usage is to write "yyterminate();" -
 * we don't want an extra ';' after the "return" because that will cause
 * some compilers to complain about unreachable statements.
 */
#ifndef yyterminate
#define yyterminate() return YY_NULL
#endif

m4_ifdef( [[M4_YY_NO_ISATTY]],,
[[
#ifndef YY_ISATTY
m4_if_cxx_streamio([[
/* There is no portable way to get an associated file descriptor for a C++ stream.
 * If isatty() is available, this seems like a reasonable best guess.  If you really
 * want portable code, it is bette to have an interactive option flag.
 */
#define YY_ISATTY(file) ((file==std::cin) ? (isatty(fileno(stdin)) > 0) : 0)
]],[[
#define YY_ISATTY(file) (file ? (isatty(fileno(file)) > 0) : 0)
]])
#endif
]])

/* Report a fatal error. */
#ifndef YY_FATAL_ERROR
#  ifdef YYENABLE_NLS
m4_if_reentrant(m4_dnl
#    define YY_FATAL_ERROR(msg) yy_fatal_error(YY_(msg), yyscanner)
#  else
#    define YY_FATAL_ERROR(msg) yy_fatal_error(msg, yyscanner)
,[[m4_dnl
#    define YY_FATAL_ERROR(msg) yy_fatal_error(YY_(msg))
#  else
#    define YY_FATAL_ERROR(msg) yy_fatal_error(msg)
]])[[]]m4_dnl
#  endif
#endif

m4_dnl NOTE: if porting to a simple OS, EXIT_FAILURE may be preferred here.
/* The exit() code for fatal errors. */
#ifndef YY_EXIT_FAILURE
#define YY_EXIT_FAILURE 2
#endif

/* Report a non-fatal error. (experimental) */
#ifndef YY_NONFATAL_ERROR
#define YY_NONFATAL_ERROR YY_FATAL_ERROR
#endif

m4_if_cxx_only([[
m4_define([[M4_YY_GLOBAL_FATAL_ERROR]],[[YY_GLOBAL_FATAL_ERROR($*)]])
m4_define([[M4_YY_GLOBAL_NONFATAL_ERROR]],[[YY_GLOBAL_NONFATAL_ERROR($*)]])
#ifndef YY_GLOBAL_FATAL_ERROR
#define YY_GLOBAL_FATAL_ERROR M4_YY_LEX_CLASS(::)LexerClassError
#endif
#ifndef YY_GLOBAL_NONFATAL_ERROR
#define YY_GLOBAL_NONFATAL_ERROR M4_YY_LEX_CLASS(::)LexerClassError
#endif
]],[[
m4_define([[M4_YY_GLOBAL_FATAL_ERROR]],[[YY_FATAL_ERROR($*)]])
m4_define([[M4_YY_GLOBAL_NONFATAL_ERROR]],[[YY_NONFATAL_ERROR($*)]])
]])

/* Code executed at the beginning of each rule, after yytext and yyleng
 * have been set up.
 */
#ifndef YY_USER_ACTION
#define YY_USER_ACTION
#endif

/* Code executed at the end of each rule. */
#ifndef YY_BREAK
#define YY_BREAK break;
#endif

