/****************** Private Function Prototypes **********************/

m4_if_tables_serialization([[
m4_if_c_only([[
M4_FUNC_PROTO(static int, yytbl_hdr_read, struct yytbl_hdr *th, struct yytbl_reader *rd);
M4_FUNC_PROTO(static struct yytbl_dmap *, yytbl_dmap_lookup, struct yytbl_dmap *dmap, int id);
M4_FUNC_PROTO(static int, yytbl_data_load, struct yytbl_dmap *dmap, struct yytbl_reader *rd);
M4_FUNC_PROTO(static int, yytbl_fload, M4_INSTREAM *fp, const char *key);
]],
[[
M4_FUNC_PROTO_NG(static int, yytbl_hdr_read, struct yytbl_hdr *th, struct yytbl_reader *rd);
M4_FUNC_PROTO_NG(static struct yytbl_dmap *, yytbl_dmap_lookup, struct yytbl_dmap *dmap, int id);
M4_FUNC_PROTO_NG(static int, yytbl_data_load, struct yytbl_dmap *dmap, struct yytbl_reader *rd);
M4_FUNC_PROTO_NG(static int, yytbl_fload, M4_INSTREAM *fp, const char *key);
]])
M4_FUNC_PROTO_NG(static flex_int32_t, yytbl_calc_total_len, const struct yytbl_data *tbl);
M4_FUNC_PROTO_NG(static int, yytbl_read8, void *v, struct yytbl_reader *rd);
M4_FUNC_PROTO_NG(static int, yytbl_read16, void *v, struct yytbl_reader *rd);
M4_FUNC_PROTO_NG(static int, yytbl_read32, void *v, struct yytbl_reader *rd);
]])

m4_if_cxx_or_reentrant([[
M4_FUNC_PROTO(static int, yy_init_globals);
]])

M4_FUNC_PROTO(static void, yyensure_buffer_stack);
M4_FUNC_PROTO(static void, yy_load_buffer_state);
M4_FUNC_PROTO(static void, yy_init_buffer, YY_BUFFER_STATE b, M4_INSTREAM *file);
M4_FUNC_PROTO(static yy_state_type, yy_get_previous_state);
M4_FUNC_PROTO(static yy_state_type, yy_try_NUL_trans, yy_state_type current_state);
M4_FUNC_PROTO(static int, yy_get_next_buffer);
M4_FUNC_PROTO(static void, yy_fatal_error, const char *msg);

m4_ifdef( [[M4_YY_NO_UNPUT]],,[[
M4_FUNC_PROTO(static void, yyunput, int c, char *buf_ptr);
]])

m4_if_c_only([[
m4_ifdef( [[M4_YY_TEXT_IS_ARRAY]],[[
M4_FUNC_PROTO_NG(static void, yy_flex_strncpy, char *dest, const char *src, unsigned int nmax);
]])

#ifdef YY_NEED_STRLEN
M4_FUNC_PROTO_NG(static int, yy_flex_strlen, const char *str);
#else
#define yy_flex_strlen strlen
#endif
]])

#ifndef YY_NO_INPUT
M4_FUNC_PROTO(static int, yyinput);
#endif

m4_ifdef( [[M4_YY_NO_PUSH_STATE]],,[[
M4_FUNC_PROTO(static void, yy_push_state, int new_state);
]])

m4_ifdef( [[M4_YY_NO_POP_STATE]],,[[
M4_FUNC_PROTO(static void, yy_pop_state);
]])

m4_ifdef( [[M4_YY_NO_TOP_STATE]],,[[
M4_FUNC_PROTO(static int, yy_top_state);
]])

