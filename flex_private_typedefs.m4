/**** Private typedefs ****/
typedef M4_YY_CHAR_TYPE YY_CHAR;

struct yy_trans_info
{
m4_ifdef([[M4_YY_TRANS_INFO_32BIT]],[[m4_dnl
	flex_int32_t yy_verify;
	flex_int32_t yy_nxt;
]],m4_dnl
[[m4_dnl
	flex_int16_t yy_verify;
	flex_int16_t yy_nxt;
]])m4_dnl
};

m4_ifdef( [[M4_YY_FULLSPD]],
[[
typedef const struct yy_trans_info *yy_state_type;
]],
[[
typedef int yy_state_type;
]])

m4_if_tables_serialization([[
m4_flex_include([[tables_shared.h]])
/** Describes a mapping from a serialized table id to its deserialized state in
 * this scanner.  This is the bridge between our "generic" deserialization code
 * and the specifics of this scanner. 
 */
struct yytbl_dmap {
	enum yytbl_id dm_id; /**< table identifier */
	void  **dm_arr; /**< address of pointer to store the deserialized table. */
	size_t  dm_sz; /**< local sizeof() each element in table. */
};

/** A tables-reader object to maintain some state in the read. */
struct yytbl_reader {
    M4_INSTREAM * fp; /**< input stream */
    flex_uint32_t bread; /**< bytes read since beginning of current tableset */
};
]])

m4_if_reentrant([[
/* Holds the entire state of the reentrant C scanner. */
struct yyobject_t
    {
    /* User-accessible globals (via set/get) */
M4_PUBLIC_GLOBALS()

    /* Private and other globals for use within yylex() */
M4_PRIVATE_GLOBALS()

    }; /* end struct yyobject_t */
]])

