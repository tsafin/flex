/*******************************************************************/
/* Declaration of public functions */
m4_if_c_only([[
/* Default declaration of generated scanner - a define so the user can
 * easily add parameters.
 */
#ifndef YY_DECL
m4_ifdef( [[M4_YY_BISON_LLOC]],[[m4_dnl
M4_FUNC_PROTO(extern int, yylex, YYSTYPE *yylval, YYLTYPE *yylloc);
]],[[m4_dnl
    m4_ifdef( [[M4_YY_BISON_LVAL]],[[
M4_FUNC_PROTO(extern int, yylex, YYSTYPE *yylval);
    ]],[[m4_dnl
M4_FUNC_PROTO(extern int, yylex);
    ]])m4_dnl
]])
#endif
]])

m4_ifdef( [[M4_YY_SKIP_YYWRAP]],,[[
#ifndef YY_SKIP_YYWRAP
M4_FUNC_PROTO(extern int, yywrap);
#endif
]])

M4_FUNC_PROTO(extern void, yyrestart, M4_INSTREAM *input_file);
M4_FUNC_PROTO(extern void, yy_switch_to_buffer, YY_BUFFER_STATE new_buffer);
M4_FUNC_PROTO(extern YY_BUFFER_STATE, yy_create_buffer, M4_INSTREAM *file, int size );
M4_FUNC_PROTO(extern void, yy_delete_buffer, YY_BUFFER_STATE b);
M4_FUNC_PROTO(extern void, yy_flush_buffer, YY_BUFFER_STATE b);
M4_FUNC_PROTO(extern void, yypush_buffer_state, YY_BUFFER_STATE new_buffer);
M4_FUNC_PROTO(extern void, yypop_buffer_state);

m4_if_c_only([[
M4_FUNC_PROTO(extern void *, yyalloc, yy_size_t size);
M4_FUNC_PROTO(extern void *, yyrealloc, void *ptr, yy_size_t size);
M4_FUNC_PROTO(extern void, yyfree, void *ptr);
]])

M4_FUNC_PROTO(extern YY_BUFFER_STATE, yy_scan_buffer, char *base, yy_size_t size);
M4_FUNC_PROTO(extern YY_BUFFER_STATE, yy_scan_string, const char *yy_str);
M4_FUNC_PROTO(extern YY_BUFFER_STATE, yy_scan_bytes, const char *bytes, int len);


m4_if_reentrant([[
/* Constructors for the C reentrant scanner. The destructor is
 * yylex_destroy(), which is also used to release the non-reentrant scanner.
 */
M4_FUNC_PROTO_NG(extern int, yylex_init, yyscan_t *yyscanner_return);

M4_FUNC_PROTO_NG(extern int, yylex_init_extra, YY_EXTRA_TYPE user_defined, yyscan_t *yyscanner_return);
]])
M4_FUNC_PROTO(extern void, yylex_init_state);

/*******************************************************************/
/* Accessor methods to globals.
 * These are made visible to non-reentrant scanners for convenience.
 * A nice feature would be an option to make these inline functions.
 */

m4_ifdef( [[M4_YY_NO_DESTROY]],,[[
M4_FUNC_PROTO(extern int, yylex_destroy);
]])

m4_ifdef( [[M4_YY_NO_GET_DEBUG]],,[[
M4_FUNC_PROTO(extern int, yyget_debug);
]])

m4_ifdef( [[M4_YY_NO_SET_DEBUG]],,[[
M4_FUNC_PROTO(extern void, yyset_debug, int debug_flag);
]])

m4_ifdef( [[M4_YY_NO_GET_EXTRA]],,[[
M4_FUNC_PROTO(extern YY_EXTRA_TYPE, yyget_extra);
]])

m4_ifdef( [[M4_YY_NO_SET_EXTRA]],,[[
M4_FUNC_PROTO(extern void, yyset_extra, YY_EXTRA_TYPE user_defined);
]])

m4_ifdef( [[M4_YY_NO_GET_IN]],,[[
M4_FUNC_PROTO(extern M4_INSTREAM *, yyget_in);
]])

m4_ifdef( [[M4_YY_NO_SET_IN]],,[[
M4_FUNC_PROTO(extern void, yyset_in, M4_INSTREAM *in_str);
]])

m4_ifdef( [[M4_YY_NO_GET_OUT]],,[[
M4_FUNC_PROTO(extern M4_OUTSTREAM *, yyget_out);
]])

m4_ifdef( [[M4_YY_NO_SET_OUT]],,[[
M4_FUNC_PROTO(extern void, yyset_out, M4_OUTSTREAM *out_str);
]])

m4_ifdef( [[M4_YY_NO_GET_LENG]],,[[
M4_FUNC_PROTO(extern int, yyget_leng);
]])

m4_ifdef( [[M4_YY_NO_GET_TEXT]],,[[
M4_FUNC_PROTO(extern char *, yyget_text);
]])

m4_ifdef( [[M4_YY_NO_GET_LINENO]],,[[
M4_FUNC_PROTO(extern int, yyget_lineno);
]])

m4_ifdef( [[M4_YY_NO_SET_LINENO]],,[[
M4_FUNC_PROTO(extern void, yyset_lineno, int line_number);
]])

m4_ifdef( [[M4_YY_NO_GET_COLUMN]],,[[
M4_FUNC_PROTO(extern int, yyget_column);
]])

m4_ifdef( [[M4_YY_NO_SET_COLUMN]],,[[
M4_FUNC_PROTO(extern void, yyset_column, int column_no);
]])

m4_ifdef( [[M4_YY_NO_GET_LVAL]],,[[
M4_FUNC_PROTO(extern YYSTYPE *, yyget_lval);
]])

m4_ifdef( [[M4_YY_NO_SET_LVAL]],,[[
M4_FUNC_PROTO(extern void, yyset_lval, YYSTYPE *yylval_param);
]])

m4_ifdef( [[M4_YY_NO_GET_LLOC]],,[[
M4_FUNC_PROTO(extern YYLTYPE *, yyget_lloc);
]])

m4_ifdef( [[M4_YY_NO_SET_LLOC]],,[[
M4_FUNC_PROTO(extern void, yyset_lloc, YYLTYPE *yylloc_param);
]])

m4_if_tables_serialization([[
    m4_if_c_only([[
/* Load the DFA tables from the given stream.  */
M4_FUNC_PROTO(extern int, yytables_fload, M4_INSTREAM *fp);

/* Unload the tables from memory. */
M4_FUNC_PROTO(extern int, yytables_destroy);
    ]],
    [[ m4_dnl The C++ version is a static class function.
/* Load the DFA tables from the given stream.  */
M4_FUNC_PROTO_NG(extern int, yytables_fload, M4_INSTREAM *fp);

/* Unload the tables from memory. */
M4_FUNC_PROTO_NG(extern int, yytables_destroy);
    ]])
]])
