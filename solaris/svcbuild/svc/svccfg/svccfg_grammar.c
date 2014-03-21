
# line 2 "svccfg.y"
/*
 * CDDL HEADER START
 *
 * The contents of this file are subject to the terms of the
 * Common Development and Distribution License (the "License").
 * You may not use this file except in compliance with the License.
 *
 * You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
 * or http://www.opensolaris.org/os/licensing.
 * See the License for the specific language governing permissions
 * and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL HEADER in each
 * file and include the License file at usr/src/OPENSOLARIS.LICENSE.
 * If applicable, add the following below this CDDL HEADER, with the
 * fields enclosed by brackets "[]" replaced with your own identifying
 * information: Portions Copyright [yyyy] [name of copyright owner]
 *
 * CDDL HEADER END
 */

/*
 * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
 */


#include <libintl.h>

#include "svccfg.h"

uu_list_pool_t *string_pool;


# line 36 "svccfg.y"
typedef union
#ifdef __cplusplus
	YYSTYPE
#endif
 {
	int tok;
	char *str;
	uu_list_t *uul;
} YYSTYPE;
# define SCC_VALIDATE 257
# define SCC_IMPORT 258
# define SCC_EXPORT 259
# define SCC_ARCHIVE 260
# define SCC_APPLY 261
# define SCC_EXTRACT 262
# define SCC_CLEANUP 263
# define SCC_REPOSITORY 264
# define SCC_INVENTORY 265
# define SCC_SET 266
# define SCC_END 267
# define SCC_HELP 268
# define SCC_RESTORE 269
# define SCC_LIST 270
# define SCC_ADD 271
# define SCC_DELETE 272
# define SCC_SELECT 273
# define SCC_UNSELECT 274
# define SCC_LISTPG 275
# define SCC_ADDPG 276
# define SCC_DELPG 277
# define SCC_DELHASH 278
# define SCC_LISTPROP 279
# define SCC_SETPROP 280
# define SCC_DELPROP 281
# define SCC_EDITPROP 282
# define SCC_DESCRIBE 283
# define SCC_ADDPROPVALUE 284
# define SCC_DELPROPVALUE 285
# define SCC_SETENV 286
# define SCC_UNSETENV 287
# define SCC_LISTSNAP 288
# define SCC_SELECTSNAP 289
# define SCC_REVERT 290
# define SCC_REFRESH 291
# define SCS_REDIRECT 292
# define SCS_NEWLINE 293
# define SCS_EQUALS 294
# define SCS_LPAREN 295
# define SCS_RPAREN 296
# define SCV_WORD 297
# define SCV_STRING 298
# define SCC_DELNOTIFY 299
# define SCC_SETNOTIFY 300
# define SCC_LISTNOTIFY 301

#include <inttypes.h>

#ifdef __STDC__
#include <stdlib.h>
#include <string.h>
#define	YYCONST	const
#else
#include <malloc.h>
#include <memory.h>
#define	YYCONST
#endif

#include <values.h>

#if defined(__cplusplus) || defined(__STDC__)

#if defined(__cplusplus) && defined(__EXTERN_C__)
extern "C" {
#endif
#ifndef yyerror
#if defined(__cplusplus)
	void yyerror(YYCONST char *);
#endif
#endif
#ifndef yylex
	int yylex(void);
#endif
	int yyparse(void);
#if defined(__cplusplus) && defined(__EXTERN_C__)
}
#endif

#endif

#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern int yyerrflag;
YYSTYPE yylval;
YYSTYPE yyval;
typedef int yytabelem;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
#if YYMAXDEPTH > 0
int yy_yys[YYMAXDEPTH], *yys = yy_yys;
YYSTYPE yy_yyv[YYMAXDEPTH], *yyv = yy_yyv;
#else	/* user does initial allocation */
int *yys;
YYSTYPE *yyv;
#endif
static int yymaxdepth = YYMAXDEPTH;
# define YYERRCODE 256
static YYCONST yytabelem yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
-1, 46,
	293, 145,
	297, 145,
	298, 145,
	-2, 0,
-1, 55,
	293, 145,
	297, 145,
	298, 145,
	-2, 0,
-1, 58,
	293, 151,
	-2, 0,
-1, 63,
	293, 151,
	-2, 0,
-1, 67,
	293, 151,
	-2, 0,
-1, 71,
	297, 145,
	298, 145,
	-2, 0,
-1, 74,
	293, 145,
	297, 145,
	298, 145,
	-2, 0,
-1, 75,
	293, 145,
	297, 145,
	298, 145,
	-2, 0,
-1, 77,
	293, 151,
	-2, 0,
-1, 78,
	293, 151,
	-2, 0,
-1, 83,
	293, 145,
	297, 145,
	298, 145,
	-2, 0,
-1, 307,
	295, 152,
	-2, 149,
	};
# define YYNPROD 190
# define YYLAST 533
static YYCONST yytabelem yyact[]={

     3,    44,    99,   214,   215,   214,   215,   307,   215,   220,
    44,   315,    44,    44,   221,   207,   291,   288,    93,   157,
    44,    44,    44,    88,   261,   249,   235,    44,   204,   198,
   298,   230,   196,   188,   186,   179,   295,   177,    98,    44,
   256,   175,   232,    97,    85,   173,    87,   171,    91,   225,
    96,   169,    44,   104,   265,    44,   206,   113,   115,    92,
    44,   320,    44,   164,    86,   167,   297,    44,   209,   203,
   157,   180,   183,   157,   187,   185,   178,   193,   176,   163,
   199,   201,   157,   205,   161,   159,   172,   210,   170,   211,
   212,   216,   168,   217,   218,   219,   222,   156,   223,   110,
   226,   227,   228,   229,   231,   108,   157,   233,   234,   236,
   237,   238,   239,   240,   103,   241,   106,   242,   243,   327,
   162,   200,   326,   192,   101,   160,   158,   190,    95,   224,
    44,   112,    90,     2,    42,    84,    41,    40,   157,    39,
   109,    38,    37,    36,    89,    35,   107,   194,    34,   184,
    33,   181,   105,    44,    32,   102,   244,   245,    44,   246,
   247,   248,   250,   251,   252,   100,   253,   254,   255,    94,
   257,   258,   259,   260,   262,   263,   264,   165,   266,   267,
   268,   114,   269,   270,    44,   271,    44,   273,    44,   275,
   276,   277,   278,   279,    31,   280,   281,   282,   283,   284,
   111,   285,   155,   286,   287,   289,    30,   290,   292,   293,
   294,    29,    28,    27,    44,    26,   182,    25,    44,   189,
   191,    24,   296,    23,   213,   202,   299,    22,   208,    21,
    20,   300,    19,   301,    18,    17,   302,    16,    15,    14,
    13,    12,    11,    10,     9,     8,     7,     6,     5,     4,
   303,   324,   116,     1,     0,     0,     0,     0,     0,     0,
     0,     0,   305,     0,     0,     0,   166,     0,     0,     0,
   174,     0,     0,   309,     0,   311,     0,     0,     0,     0,
   195,   197,     0,     0,     0,     0,     0,     0,     0,   312,
     0,     0,   313,     0,     0,     0,   314,     0,     0,   316,
     0,     0,     0,     0,     0,   317,     0,   318,     0,     0,
     0,   321,     0,     0,     0,     0,   322,     0,     0,     0,
   323,     0,     0,     0,     0,     0,     0,   328,    43,    45,
    46,    48,    49,    51,    52,    47,    53,    54,    55,    56,
    57,    50,    58,    59,    60,    61,    62,    63,    64,    65,
    66,    67,    68,    69,    70,    71,    72,    73,    74,    75,
    76,    77,    78,    79,     0,    44,     0,     0,     0,    80,
     0,    81,    83,    82,   117,   118,   119,   121,   125,   122,
   123,   120,   124,   126,   127,   128,   129,     0,   130,   131,
   132,   133,   134,   135,   136,   137,   138,   139,   140,   141,
   142,   151,   143,   144,   145,   146,   147,   148,   149,   150,
   272,    44,   274,     0,     0,     0,     0,   152,   154,   153,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,   304,
     0,     0,     0,     0,     0,   325,     0,     0,   308,     0,
     0,     0,   329,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
   306,     0,     0,     0,     0,     0,     0,   310,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,   319 };
static YYCONST yytabelem yypact[]={

    72,    72,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,
-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,
-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,
-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,
-10000000,-10000000,-10000000,  -231,-10000000,  -233,  -124,  -238,  -128,  -254,
  -132,  -142,  -140,  -151,  -157,  -125,   -75,   118,  -159,  -171,
  -172,  -177,   -79,  -191,  -205,  -209,  -211,  -215,  -219,  -221,
  -105,  -107,  -222,  -223,  -129,  -133,  -109,  -224,  -227,  -135,
  -231,  -228,  -241,  -188,-10000000,-10000000,  -231,-10000000,  -231,  -292,
  -231,-10000000,  -231,  -231,  -283,  -231,-10000000,  -163,  -248,  -231,
  -231,  -231,  -266,  -231,-10000000,  -255,  -231,  -271,  -231,  -231,
  -231,  -292,  -231,-10000000,  -231,-10000000,  -231,  -231,-10000000,-10000000,
-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,
-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,
-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,
-10000000,-10000000,-10000000,-10000000,-10000000,  -231,  -231,-10000000,  -231,  -231,
  -272,  -231,  -231,  -231,-10000000,  -231,  -231,  -231,  -257,  -231,
  -231,  -231,  -273,  -231,  -231,  -231,  -240,  -231,  -231,  -231,
-10000000,  -231,  -292,-10000000,  -231,  -294,  -231,  -294,  -231,  -292,
  -231,  -292,  -231,-10000000,  -231,  -231,  -231,  -231,  -231,-10000000,
  -231,-10000000,  -292,  -280,  -231,-10000000,  -281,  -231,  -292,  -231,
-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,
  -261,  -226,-10000000,-10000000,  -267,  -231,-10000000,-10000000,-10000000,-10000000,
  -231,-10000000,  -231,-10000000,-10000000,  -231,-10000000,-10000000,-10000000,-10000000,
-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,  -231,
-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,  -278,-10000000,-10000000,-10000000,
-10000000,  -231,-10000000,-10000000,-10000000,  -290,-10000000,-10000000,-10000000,-10000000,
-10000000,-10000000,  -292,-10000000,  -231,-10000000,-10000000,-10000000,-10000000,-10000000,
-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,-10000000,  -231,-10000000,
-10000000,  -231,-10000000,-10000000,-10000000,  -231,-10000000,  -286,  -231,-10000000,
-10000000,-10000000,-10000000,-10000000,  -231,-10000000,  -231,  -294,  -234,-10000000,
  -231,-10000000,-10000000,-10000000,-10000000,  -231,-10000000,-10000000,-10000000,  -231,
-10000000,-10000000,-10000000,-10000000,  -174,  -294,  -231,-10000000,-10000000,  -294 };
static YYCONST yytabelem yypgo[]={

     0,   253,   252,   224,   202,   144,   251,   133,     0,   249,
   248,   247,   246,   245,   244,   243,   242,   241,   240,   239,
   238,   237,   235,   234,   232,   230,   229,   227,   223,   221,
   217,   215,   213,   212,   211,   206,   194,   154,   150,   148,
   145,   143,   142,   141,   139,   137,   136,   134 };
static YYCONST yytabelem yyr1[]={

     0,     1,     1,     7,     7,     7,     7,     7,     7,     7,
     7,     7,     7,     7,     7,     7,     7,     7,     7,     7,
     7,     7,     7,     7,     7,     7,     7,     7,     7,     7,
     7,     7,     7,     7,     7,     7,     7,     7,     7,     7,
     7,     7,     7,     7,    44,    44,     9,     9,     9,    10,
    10,    11,    11,    11,    12,    12,    12,    12,    12,    13,
    13,    13,    13,    13,    14,    14,    15,    15,    15,    16,
    16,    16,    17,    17,    17,    18,    18,    19,    19,    20,
    20,    21,    21,    21,    22,    22,    23,    23,    24,    24,
    24,    25,    25,    26,    26,    27,    27,    28,    28,    29,
    29,    30,    30,    30,    31,    31,    32,    32,    32,    32,
    32,    33,    33,    34,    34,    35,    35,    35,    36,    36,
    36,    37,    37,    38,    38,    39,    39,    40,    40,    41,
    41,    42,    42,    43,    43,    45,    45,    45,    46,    46,
    46,    46,    47,    47,     8,     5,     5,     6,     6,     3,
     3,     4,     4,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2 };
static YYCONST yytabelem yyr2[]={

     0,     2,     4,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     5,     5,     7,     7,     5,     7,     7,
     7,     5,     7,     7,     7,    11,     9,    13,     7,     5,
     7,     9,    11,     7,     7,     7,     7,     9,     7,     5,
     9,     7,     7,     9,     7,     7,     7,     7,     7,     5,
     7,     5,     7,     7,     7,     7,     7,     7,     7,     9,
     7,     7,     7,     5,     7,     7,     7,    11,     7,     7,
     7,     7,     9,     7,     7,     7,    11,    13,    17,     7,
     5,     7,     7,     5,     7,     7,     5,     7,     9,    11,
     7,     9,     7,     7,     7,     7,     7,     5,     7,     7,
     7,     7,     7,     5,     7,     7,     9,     7,     5,     7,
     9,     7,     7,     7,     2,     1,     5,     3,     7,     3,
     3,     1,     3,     3,     3,     3,     3,     3,     3,     3,
     3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
     3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
     3,     3,     3,     3,     3,     3,     3,     3,     3,     3 };
static YYCONST yytabelem yychk[]={

-10000000,    -1,    -7,    -8,    -9,   -10,   -11,   -12,   -13,   -14,
   -15,   -16,   -17,   -18,   -19,   -20,   -21,   -22,   -23,   -24,
   -25,   -26,   -27,   -28,   -29,   -30,   -31,   -32,   -33,   -34,
   -35,   -36,   -37,   -38,   -39,   -40,   -41,   -42,   -43,   -44,
   -45,   -46,   -47,   256,   293,   257,   258,   263,   259,   260,
   269,   261,   262,   264,   265,   266,   267,   268,   270,   271,
   272,   273,   274,   275,   276,   277,   278,   279,   280,   281,
   282,   283,   284,   285,   286,   287,   288,   289,   290,   291,
   297,   299,   301,   300,    -7,    -8,   297,    -8,   256,    -5,
   256,    -8,   297,   256,   297,   256,    -8,   297,   292,   256,
   297,   256,   297,   256,    -8,   292,   256,   297,   256,   297,
   256,    -5,   256,    -8,   256,    -8,    -2,   256,   257,   258,
   263,   259,   261,   262,   264,   260,   265,   266,   267,   268,
   270,   271,   272,   273,   274,   275,   276,   277,   278,   279,
   280,   281,   282,   284,   285,   286,   287,   288,   289,   290,
   291,   283,   299,   301,   300,    -4,   256,   297,   297,   256,
   297,   256,   297,   256,    -8,   256,    -4,   256,   297,   256,
   297,   256,   297,   256,    -4,   256,   297,   256,   297,   256,
    -8,   256,    -5,    -8,   256,   297,   256,   297,   256,    -5,
   256,    -5,   256,    -8,   256,    -4,   256,    -4,   256,    -8,
   256,    -8,    -5,   297,   256,    -8,   297,   256,    -5,   256,
    -8,    -8,    -8,    -3,   297,   298,    -8,    -8,    -8,    -8,
   292,   297,    -8,    -8,   292,   297,    -8,    -8,    -8,    -8,
   297,    -8,   297,    -8,    -8,   297,    -8,    -8,    -8,    -8,
    -8,    -8,    -8,    -8,    -8,    -8,    -8,    -8,    -8,   297,
    -8,    -8,    -8,    -8,    -8,    -8,   297,    -8,    -8,    -8,
    -8,   297,    -8,    -8,    -8,   294,    -8,    -8,    -8,    -8,
    -8,    -8,    -3,    -8,    -3,    -8,    -8,    -8,    -8,    -8,
    -8,    -8,    -8,    -8,    -8,    -8,    -8,    -8,   297,    -8,
    -8,   297,    -8,    -8,    -8,   297,    -8,   292,   297,    -8,
    -8,    -8,    -8,    -8,    -4,    -8,    -3,   297,    -4,    -8,
    -3,    -8,    -8,    -8,    -8,   297,    -8,    -8,    -8,    -3,
   295,    -8,    -8,    -8,    -6,    -5,   296,   293,    -8,    -5 };
static YYCONST yytabelem yydef[]={

     0,    -2,     1,     3,     4,     5,     6,     7,     8,     9,
    10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
    20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
    30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
    40,    41,    42,     0,   144,     0,    -2,     0,     0,     0,
     0,     0,     0,     0,     0,    -2,     0,     0,    -2,     0,
     0,     0,     0,    -2,     0,     0,     0,    -2,     0,     0,
     0,    -2,     0,     0,    -2,    -2,     0,    -2,    -2,     0,
   145,     0,     0,    -2,     2,    43,     0,    47,     0,     0,
     0,    51,     0,     0,     0,     0,    59,     0,     0,     0,
     0,     0,     0,     0,    69,     0,     0,     0,     0,     0,
     0,     0,     0,    79,     0,    81,     0,     0,   153,   154,
   155,   156,   157,   158,   159,   160,   161,   162,   163,   164,
   165,   166,   167,   168,   169,   170,   171,   172,   173,   174,
   175,   176,   177,   178,   179,   180,   181,   182,   183,   184,
   185,   186,   187,   188,   189,     0,     0,   152,     0,     0,
     0,     0,     0,     0,    93,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,   110,     0,     0,
   113,     0,     0,   116,     0,     0,     0,     0,     0,     0,
     0,     0,     0,   127,     0,     0,     0,     0,     0,   133,
     0,    44,     0,     0,     0,   138,     0,     0,     0,     0,
    46,    48,    49,   146,   149,   150,    50,    52,    53,    54,
     0,     0,    58,    60,     0,     0,    63,    64,    65,    66,
     0,    68,     0,    71,    72,     0,    74,    75,    76,    77,
    78,    80,    82,    83,    84,    85,    86,    87,    88,     0,
    90,    91,    92,    94,    95,    96,   151,    98,    99,   100,
   101,     0,   103,   104,   105,   151,   109,   111,   112,   114,
   115,   117,     0,   120,     0,   122,   123,   124,   125,   126,
   128,   129,   130,   131,   132,   134,    45,   135,     0,   137,
   139,     0,   141,   142,   143,     0,    56,     0,     0,    61,
    67,    70,    73,    89,     0,   102,     0,    -2,     0,   118,
     0,   121,   136,   140,    55,     0,    62,    97,   106,     0,
   145,   119,    57,   107,     0,   147,     0,   145,   108,   148 };
typedef struct
#ifdef __cplusplus
	yytoktype
#endif
{
#ifdef __cplusplus
const
#endif
char *t_name; int t_val; } yytoktype;
#ifndef YYDEBUG
#	define YYDEBUG	0	/* don't allow debugging */
#endif

#if YYDEBUG

yytoktype yytoks[] =
{
	"SCC_VALIDATE",	257,
	"SCC_IMPORT",	258,
	"SCC_EXPORT",	259,
	"SCC_ARCHIVE",	260,
	"SCC_APPLY",	261,
	"SCC_EXTRACT",	262,
	"SCC_CLEANUP",	263,
	"SCC_REPOSITORY",	264,
	"SCC_INVENTORY",	265,
	"SCC_SET",	266,
	"SCC_END",	267,
	"SCC_HELP",	268,
	"SCC_RESTORE",	269,
	"SCC_LIST",	270,
	"SCC_ADD",	271,
	"SCC_DELETE",	272,
	"SCC_SELECT",	273,
	"SCC_UNSELECT",	274,
	"SCC_LISTPG",	275,
	"SCC_ADDPG",	276,
	"SCC_DELPG",	277,
	"SCC_DELHASH",	278,
	"SCC_LISTPROP",	279,
	"SCC_SETPROP",	280,
	"SCC_DELPROP",	281,
	"SCC_EDITPROP",	282,
	"SCC_DESCRIBE",	283,
	"SCC_ADDPROPVALUE",	284,
	"SCC_DELPROPVALUE",	285,
	"SCC_SETENV",	286,
	"SCC_UNSETENV",	287,
	"SCC_LISTSNAP",	288,
	"SCC_SELECTSNAP",	289,
	"SCC_REVERT",	290,
	"SCC_REFRESH",	291,
	"SCS_REDIRECT",	292,
	"SCS_NEWLINE",	293,
	"SCS_EQUALS",	294,
	"SCS_LPAREN",	295,
	"SCS_RPAREN",	296,
	"SCV_WORD",	297,
	"SCV_STRING",	298,
	"SCC_DELNOTIFY",	299,
	"SCC_SETNOTIFY",	300,
	"SCC_LISTNOTIFY",	301,
	"-unknown-",	-1	/* ends search */
};

#ifdef __cplusplus
const
#endif
char * yyreds[] =
{
	"-no such reduction-",
	"commands : command",
	"commands : commands command",
	"command : terminator",
	"command : validate_cmd",
	"command : import_cmd",
	"command : cleanup_cmd",
	"command : export_cmd",
	"command : archive_cmd",
	"command : restore_cmd",
	"command : apply_cmd",
	"command : extract_cmd",
	"command : repository_cmd",
	"command : inventory_cmd",
	"command : set_cmd",
	"command : end_cmd",
	"command : help_cmd",
	"command : list_cmd",
	"command : add_cmd",
	"command : delete_cmd",
	"command : select_cmd",
	"command : unselect_cmd",
	"command : listpg_cmd",
	"command : addpg_cmd",
	"command : delpg_cmd",
	"command : delhash_cmd",
	"command : listprop_cmd",
	"command : setprop_cmd",
	"command : delprop_cmd",
	"command : editprop_cmd",
	"command : describe_cmd",
	"command : addpropvalue_cmd",
	"command : delpropvalue_cmd",
	"command : setenv_cmd",
	"command : unsetenv_cmd",
	"command : listsnap_cmd",
	"command : selectsnap_cmd",
	"command : revert_cmd",
	"command : refresh_cmd",
	"command : unknown_cmd",
	"command : delnotify_cmd",
	"command : listnotify_cmd",
	"command : setnotify_cmd",
	"command : error terminator",
	"unknown_cmd : SCV_WORD terminator",
	"unknown_cmd : SCV_WORD string_list terminator",
	"validate_cmd : SCC_VALIDATE SCV_WORD terminator",
	"validate_cmd : SCC_VALIDATE terminator",
	"validate_cmd : SCC_VALIDATE error terminator",
	"import_cmd : SCC_IMPORT string_list terminator",
	"import_cmd : SCC_IMPORT error terminator",
	"cleanup_cmd : SCC_CLEANUP terminator",
	"cleanup_cmd : SCC_CLEANUP SCV_WORD terminator",
	"cleanup_cmd : SCC_CLEANUP error terminator",
	"export_cmd : SCC_EXPORT SCV_WORD terminator",
	"export_cmd : SCC_EXPORT SCV_WORD SCS_REDIRECT SCV_WORD terminator",
	"export_cmd : SCC_EXPORT SCV_WORD SCV_WORD terminator",
	"export_cmd : SCC_EXPORT SCV_WORD SCV_WORD SCS_REDIRECT SCV_WORD terminator",
	"export_cmd : SCC_EXPORT error terminator",
	"archive_cmd : SCC_ARCHIVE terminator",
	"archive_cmd : SCC_ARCHIVE SCV_WORD terminator",
	"archive_cmd : SCC_ARCHIVE SCS_REDIRECT SCV_WORD terminator",
	"archive_cmd : SCC_ARCHIVE SCV_WORD SCS_REDIRECT SCV_WORD terminator",
	"archive_cmd : SCC_ARCHIVE error terminator",
	"restore_cmd : SCC_RESTORE SCV_WORD terminator",
	"restore_cmd : SCC_RESTORE error terminator",
	"apply_cmd : SCC_APPLY SCV_WORD terminator",
	"apply_cmd : SCC_APPLY SCV_WORD SCV_WORD terminator",
	"apply_cmd : SCC_APPLY error terminator",
	"extract_cmd : SCC_EXTRACT terminator",
	"extract_cmd : SCC_EXTRACT SCS_REDIRECT SCV_WORD terminator",
	"extract_cmd : SCC_EXTRACT error terminator",
	"repository_cmd : SCC_REPOSITORY SCV_WORD terminator",
	"repository_cmd : SCC_REPOSITORY SCV_WORD SCV_WORD terminator",
	"repository_cmd : SCC_REPOSITORY error terminator",
	"inventory_cmd : SCC_INVENTORY SCV_WORD terminator",
	"inventory_cmd : SCC_INVENTORY error terminator",
	"set_cmd : SCC_SET string_list terminator",
	"set_cmd : SCC_SET error terminator",
	"end_cmd : SCC_END terminator",
	"end_cmd : SCC_END error terminator",
	"help_cmd : SCC_HELP terminator",
	"help_cmd : SCC_HELP command_token terminator",
	"help_cmd : SCC_HELP error terminator",
	"list_cmd : SCC_LIST opt_word terminator",
	"list_cmd : SCC_LIST error terminator",
	"add_cmd : SCC_ADD SCV_WORD terminator",
	"add_cmd : SCC_ADD error terminator",
	"delete_cmd : SCC_DELETE SCV_WORD terminator",
	"delete_cmd : SCC_DELETE SCV_WORD SCV_WORD terminator",
	"delete_cmd : SCC_DELETE error terminator",
	"select_cmd : SCC_SELECT SCV_WORD terminator",
	"select_cmd : SCC_SELECT error terminator",
	"unselect_cmd : SCC_UNSELECT terminator",
	"unselect_cmd : SCC_UNSELECT error terminator",
	"listpg_cmd : SCC_LISTPG opt_word terminator",
	"listpg_cmd : SCC_LISTPG error terminator",
	"addpg_cmd : SCC_ADDPG SCV_WORD SCV_WORD opt_word terminator",
	"addpg_cmd : SCC_ADDPG error terminator",
	"delpg_cmd : SCC_DELPG SCV_WORD terminator",
	"delpg_cmd : SCC_DELPG error terminator",
	"delhash_cmd : SCC_DELHASH SCV_WORD terminator",
	"delhash_cmd : SCC_DELHASH SCV_WORD SCV_WORD terminator",
	"delhash_cmd : SCC_DELHASH error terminator",
	"listprop_cmd : SCC_LISTPROP opt_word terminator",
	"listprop_cmd : SCC_LISTPROP error terminator",
	"setprop_cmd : SCC_SETPROP SCV_WORD SCS_EQUALS string terminator",
	"setprop_cmd : SCC_SETPROP SCV_WORD SCS_EQUALS SCV_WORD string terminator",
	"setprop_cmd : SCC_SETPROP SCV_WORD SCS_EQUALS opt_word SCS_LPAREN multiline_string_list SCS_RPAREN terminator",
	"setprop_cmd : SCC_SETPROP error terminator",
	"setprop_cmd : SCC_SETPROP error",
	"delprop_cmd : SCC_DELPROP SCV_WORD terminator",
	"delprop_cmd : SCC_DELPROP error terminator",
	"editprop_cmd : SCC_EDITPROP terminator",
	"editprop_cmd : SCC_EDITPROP error terminator",
	"describe_cmd : SCC_DESCRIBE string_list terminator",
	"describe_cmd : SCC_DESCRIBE terminator",
	"describe_cmd : SCC_DESCRIBE error terminator",
	"addpropvalue_cmd : SCC_ADDPROPVALUE SCV_WORD string terminator",
	"addpropvalue_cmd : SCC_ADDPROPVALUE SCV_WORD string string terminator",
	"addpropvalue_cmd : SCC_ADDPROPVALUE error terminator",
	"delpropvalue_cmd : SCC_DELPROPVALUE SCV_WORD string terminator",
	"delpropvalue_cmd : SCC_DELPROPVALUE error terminator",
	"setenv_cmd : SCC_SETENV string_list terminator",
	"setenv_cmd : SCC_SETENV error terminator",
	"unsetenv_cmd : SCC_UNSETENV string_list terminator",
	"unsetenv_cmd : SCC_UNSETENV error terminator",
	"listsnap_cmd : SCC_LISTSNAP terminator",
	"listsnap_cmd : SCC_LISTSNAP error terminator",
	"selectsnap_cmd : SCC_SELECTSNAP opt_word terminator",
	"selectsnap_cmd : SCC_SELECTSNAP error terminator",
	"revert_cmd : SCC_REVERT opt_word terminator",
	"revert_cmd : SCC_REVERT error terminator",
	"refresh_cmd : SCC_REFRESH terminator",
	"refresh_cmd : SCC_REFRESH error terminator",
	"delnotify_cmd : SCC_DELNOTIFY SCV_WORD terminator",
	"delnotify_cmd : SCC_DELNOTIFY SCV_WORD SCV_WORD terminator",
	"delnotify_cmd : SCC_DELNOTIFY error terminator",
	"listnotify_cmd : SCC_LISTNOTIFY terminator",
	"listnotify_cmd : SCC_LISTNOTIFY SCV_WORD terminator",
	"listnotify_cmd : SCC_LISTNOTIFY SCV_WORD SCV_WORD terminator",
	"listnotify_cmd : SCC_LISTNOTIFY error terminator",
	"setnotify_cmd : SCC_SETNOTIFY string_list terminator",
	"setnotify_cmd : SCC_SETNOTIFY error terminator",
	"terminator : SCS_NEWLINE",
	"string_list : /* empty */",
	"string_list : string_list string",
	"multiline_string_list : string_list",
	"multiline_string_list : multiline_string_list SCS_NEWLINE string_list",
	"string : SCV_WORD",
	"string : SCV_STRING",
	"opt_word : /* empty */",
	"opt_word : SCV_WORD",
	"command_token : SCC_VALIDATE",
	"command_token : SCC_IMPORT",
	"command_token : SCC_CLEANUP",
	"command_token : SCC_EXPORT",
	"command_token : SCC_APPLY",
	"command_token : SCC_EXTRACT",
	"command_token : SCC_REPOSITORY",
	"command_token : SCC_ARCHIVE",
	"command_token : SCC_INVENTORY",
	"command_token : SCC_SET",
	"command_token : SCC_END",
	"command_token : SCC_HELP",
	"command_token : SCC_LIST",
	"command_token : SCC_ADD",
	"command_token : SCC_DELETE",
	"command_token : SCC_SELECT",
	"command_token : SCC_UNSELECT",
	"command_token : SCC_LISTPG",
	"command_token : SCC_ADDPG",
	"command_token : SCC_DELPG",
	"command_token : SCC_DELHASH",
	"command_token : SCC_LISTPROP",
	"command_token : SCC_SETPROP",
	"command_token : SCC_DELPROP",
	"command_token : SCC_EDITPROP",
	"command_token : SCC_ADDPROPVALUE",
	"command_token : SCC_DELPROPVALUE",
	"command_token : SCC_SETENV",
	"command_token : SCC_UNSETENV",
	"command_token : SCC_LISTSNAP",
	"command_token : SCC_SELECTSNAP",
	"command_token : SCC_REVERT",
	"command_token : SCC_REFRESH",
	"command_token : SCC_DESCRIBE",
	"command_token : SCC_DELNOTIFY",
	"command_token : SCC_LISTNOTIFY",
	"command_token : SCC_SETNOTIFY",
};
#endif /* YYDEBUG */
# line	1 "/opt/local/bin/..//share/lib/ccs/yaccpar"
/*
 * CDDL HEADER START
 *
 * The contents of this file are subject to the terms of the
 * Common Development and Distribution License, Version 1.0 only
 * (the "License").  You may not use this file except in compliance
 * with the License.
 *
 * You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
 * or http://www.opensolaris.org/os/licensing.
 * See the License for the specific language governing permissions
 * and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL HEADER in each
 * file and include the License file at usr/src/OPENSOLARIS.LICENSE.
 * If applicable, add the following below this CDDL HEADER, with the
 * fields enclosed by brackets "[]" replaced with your own identifying
 * information: Portions Copyright [yyyy] [name of copyright owner]
 *
 * CDDL HEADER END
 */
/*
 * Copyright 1993 Sun Microsystems, Inc.  All rights reserved.
 * Use is subject to license terms.
 */

/* Copyright (c) 1988 AT&T */
/* All Rights Reserved */

#pragma ident	"%Z%%M%	%I%	%E% SMI"

/*
** Skeleton parser driver for yacc output
*/

/*
** yacc user known macros and defines
*/
#define YYERROR		goto yyerrlab
#define YYACCEPT	return(0)
#define YYABORT		return(1)
#define YYBACKUP( newtoken, newvalue )\
{\
	if ( yychar >= 0 || ( yyr2[ yytmp ] >> 1 ) != 1 )\
	{\
		yyerror( "syntax error - cannot backup" );\
		goto yyerrlab;\
	}\
	yychar = newtoken;\
	yystate = *yyps;\
	yylval = newvalue;\
	goto yynewstate;\
}
#define YYRECOVERING()	(!!yyerrflag)
#define YYNEW(type)	malloc(sizeof(type) * yynewmax)
#define YYCOPY(to, from, type) \
	(type *) memcpy(to, (char *) from, yymaxdepth * sizeof (type))
#define YYENLARGE( from, type) \
	(type *) realloc((char *) from, yynewmax * sizeof(type))
#ifndef YYDEBUG
#	define YYDEBUG	1	/* make debugging available */
#endif

/*
** user known globals
*/
int yydebug;			/* set to 1 to get debugging */

/*
** driver internal defines
*/
#define YYFLAG		(-10000000)

/*
** global variables used by the parser
*/
YYSTYPE *yypv;			/* top of value stack */
int *yyps;			/* top of state stack */

int yystate;			/* current state */
int yytmp;			/* extra var (lasts between blocks) */

int yynerrs;			/* number of errors */
int yyerrflag;			/* error recovery flag */
int yychar;			/* current input token number */



#ifdef YYNMBCHARS
#define YYLEX()		yycvtok(yylex())
/*
** yycvtok - return a token if i is a wchar_t value that exceeds 255.
**	If i<255, i itself is the token.  If i>255 but the neither 
**	of the 30th or 31st bit is on, i is already a token.
*/
#if defined(__STDC__) || defined(__cplusplus)
int yycvtok(int i)
#else
int yycvtok(i) int i;
#endif
{
	int first = 0;
	int last = YYNMBCHARS - 1;
	int mid;
	wchar_t j;

	if(i&0x60000000){/*Must convert to a token. */
		if( yymbchars[last].character < i ){
			return i;/*Giving up*/
		}
		while ((last>=first)&&(first>=0)) {/*Binary search loop*/
			mid = (first+last)/2;
			j = yymbchars[mid].character;
			if( j==i ){/*Found*/ 
				return yymbchars[mid].tvalue;
			}else if( j<i ){
				first = mid + 1;
			}else{
				last = mid -1;
			}
		}
		/*No entry in the table.*/
		return i;/* Giving up.*/
	}else{/* i is already a token. */
		return i;
	}
}
#else/*!YYNMBCHARS*/
#define YYLEX()		yylex()
#endif/*!YYNMBCHARS*/

/*
** yyparse - return 0 if worked, 1 if syntax error not recovered from
*/
#if defined(__STDC__) || defined(__cplusplus)
int yyparse(void)
#else
int yyparse()
#endif
{
	register YYSTYPE *yypvt = 0;	/* top of value stack for $vars */

#if defined(__cplusplus) || defined(lint)
/*
	hacks to please C++ and lint - goto's inside
	switch should never be executed
*/
	static int __yaccpar_lint_hack__ = 0;
	switch (__yaccpar_lint_hack__)
	{
		case 1: goto yyerrlab;
		case 2: goto yynewstate;
	}
#endif

	/*
	** Initialize externals - yyparse may be called more than once
	*/
	yypv = &yyv[-1];
	yyps = &yys[-1];
	yystate = 0;
	yytmp = 0;
	yynerrs = 0;
	yyerrflag = 0;
	yychar = -1;

#if YYMAXDEPTH <= 0
	if (yymaxdepth <= 0)
	{
		if ((yymaxdepth = YYEXPAND(0)) <= 0)
		{
			yyerror("yacc initialization error");
			YYABORT;
		}
	}
#endif

	{
		register YYSTYPE *yy_pv;	/* top of value stack */
		register int *yy_ps;		/* top of state stack */
		register int yy_state;		/* current state */
		register int  yy_n;		/* internal state number info */
	goto yystack;	/* moved from 6 lines above to here to please C++ */

		/*
		** get globals into registers.
		** branch to here only if YYBACKUP was called.
		*/
	yynewstate:
		yy_pv = yypv;
		yy_ps = yyps;
		yy_state = yystate;
		goto yy_newstate;

		/*
		** get globals into registers.
		** either we just started, or we just finished a reduction
		*/
	yystack:
		yy_pv = yypv;
		yy_ps = yyps;
		yy_state = yystate;

		/*
		** top of for (;;) loop while no reductions done
		*/
	yy_stack:
		/*
		** put a state and value onto the stacks
		*/
#if YYDEBUG
		/*
		** if debugging, look up token value in list of value vs.
		** name pairs.  0 and negative (-1) are special values.
		** Note: linear search is used since time is not a real
		** consideration while debugging.
		*/
		if ( yydebug )
		{
			register int yy_i;

			printf( "State %d, token ", yy_state );
			if ( yychar == 0 )
				printf( "end-of-file\n" );
			else if ( yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( yy_i = 0; yytoks[yy_i].t_val >= 0;
					yy_i++ )
				{
					if ( yytoks[yy_i].t_val == yychar )
						break;
				}
				printf( "%s\n", yytoks[yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ++yy_ps >= &yys[ yymaxdepth ] )	/* room on stack? */
		{
			/*
			** reallocate and recover.  Note that pointers
			** have to be reset, or bad things will happen
			*/
			long yyps_index = (yy_ps - yys);
			long yypv_index = (yy_pv - yyv);
			long yypvt_index = (yypvt - yyv);
			int yynewmax;
#ifdef YYEXPAND
			yynewmax = YYEXPAND(yymaxdepth);
#else
			yynewmax = 2 * yymaxdepth;	/* double table size */
			if (yymaxdepth == YYMAXDEPTH)	/* first time growth */
			{
				char *newyys = (char *)YYNEW(int);
				char *newyyv = (char *)YYNEW(YYSTYPE);
				if (newyys != 0 && newyyv != 0)
				{
					yys = YYCOPY(newyys, yys, int);
					yyv = YYCOPY(newyyv, yyv, YYSTYPE);
				}
				else
					yynewmax = 0;	/* failed */
			}
			else				/* not first time */
			{
				yys = YYENLARGE(yys, int);
				yyv = YYENLARGE(yyv, YYSTYPE);
				if (yys == 0 || yyv == 0)
					yynewmax = 0;	/* failed */
			}
#endif
			if (yynewmax <= yymaxdepth)	/* tables not expanded */
			{
				yyerror( "yacc stack overflow" );
				YYABORT;
			}
			yymaxdepth = yynewmax;

			yy_ps = yys + yyps_index;
			yy_pv = yyv + yypv_index;
			yypvt = yyv + yypvt_index;
		}
		*yy_ps = yy_state;
		*++yy_pv = yyval;

		/*
		** we have a new state - find out what to do
		*/
	yy_newstate:
		if ( ( yy_n = yypact[ yy_state ] ) <= YYFLAG )
			goto yydefault;		/* simple state */
#if YYDEBUG
		/*
		** if debugging, need to mark whether new token grabbed
		*/
		yytmp = yychar < 0;
#endif
		if ( ( yychar < 0 ) && ( ( yychar = YYLEX() ) < 0 ) )
			yychar = 0;		/* reached EOF */
#if YYDEBUG
		if ( yydebug && yytmp )
		{
			register int yy_i;

			printf( "Received token " );
			if ( yychar == 0 )
				printf( "end-of-file\n" );
			else if ( yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( yy_i = 0; yytoks[yy_i].t_val >= 0;
					yy_i++ )
				{
					if ( yytoks[yy_i].t_val == yychar )
						break;
				}
				printf( "%s\n", yytoks[yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ( ( yy_n += yychar ) < 0 ) || ( yy_n >= YYLAST ) )
			goto yydefault;
		if ( yychk[ yy_n = yyact[ yy_n ] ] == yychar )	/*valid shift*/
		{
			yychar = -1;
			yyval = yylval;
			yy_state = yy_n;
			if ( yyerrflag > 0 )
				yyerrflag--;
			goto yy_stack;
		}

	yydefault:
		if ( ( yy_n = yydef[ yy_state ] ) == -2 )
		{
#if YYDEBUG
			yytmp = yychar < 0;
#endif
			if ( ( yychar < 0 ) && ( ( yychar = YYLEX() ) < 0 ) )
				yychar = 0;		/* reached EOF */
#if YYDEBUG
			if ( yydebug && yytmp )
			{
				register int yy_i;

				printf( "Received token " );
				if ( yychar == 0 )
					printf( "end-of-file\n" );
				else if ( yychar < 0 )
					printf( "-none-\n" );
				else
				{
					for ( yy_i = 0;
						yytoks[yy_i].t_val >= 0;
						yy_i++ )
					{
						if ( yytoks[yy_i].t_val
							== yychar )
						{
							break;
						}
					}
					printf( "%s\n", yytoks[yy_i].t_name );
				}
			}
#endif /* YYDEBUG */
			/*
			** look through exception table
			*/
			{
				register YYCONST int *yyxi = yyexca;

				while ( ( *yyxi != -1 ) ||
					( yyxi[1] != yy_state ) )
				{
					yyxi += 2;
				}
				while ( ( *(yyxi += 2) >= 0 ) &&
					( *yyxi != yychar ) )
					;
				if ( ( yy_n = yyxi[1] ) < 0 )
					YYACCEPT;
			}
		}

		/*
		** check for syntax error
		*/
		if ( yy_n == 0 )	/* have an error */
		{
			/* no worry about speed here! */
			switch ( yyerrflag )
			{
			case 0:		/* new error */
				yyerror( "syntax error" );
				goto skip_init;
			yyerrlab:
				/*
				** get globals into registers.
				** we have a user generated syntax type error
				*/
				yy_pv = yypv;
				yy_ps = yyps;
				yy_state = yystate;
			skip_init:
				yynerrs++;
				/* FALLTHRU */
			case 1:
			case 2:		/* incompletely recovered error */
					/* try again... */
				yyerrflag = 3;
				/*
				** find state where "error" is a legal
				** shift action
				*/
				while ( yy_ps >= yys )
				{
					yy_n = yypact[ *yy_ps ] + YYERRCODE;
					if ( yy_n >= 0 && yy_n < YYLAST &&
						yychk[yyact[yy_n]] == YYERRCODE)					{
						/*
						** simulate shift of "error"
						*/
						yy_state = yyact[ yy_n ];
						goto yy_stack;
					}
					/*
					** current state has no shift on
					** "error", pop stack
					*/
#if YYDEBUG
#	define _POP_ "Error recovery pops state %d, uncovers state %d\n"
					if ( yydebug )
						printf( _POP_, *yy_ps,
							yy_ps[-1] );
#	undef _POP_
#endif
					yy_ps--;
					yy_pv--;
				}
				/*
				** there is no state on stack with "error" as
				** a valid shift.  give up.
				*/
				YYABORT;
			case 3:		/* no shift yet; eat a token */
#if YYDEBUG
				/*
				** if debugging, look up token in list of
				** pairs.  0 and negative shouldn't occur,
				** but since timing doesn't matter when
				** debugging, it doesn't hurt to leave the
				** tests here.
				*/
				if ( yydebug )
				{
					register int yy_i;

					printf( "Error recovery discards " );
					if ( yychar == 0 )
						printf( "token end-of-file\n" );
					else if ( yychar < 0 )
						printf( "token -none-\n" );
					else
					{
						for ( yy_i = 0;
							yytoks[yy_i].t_val >= 0;
							yy_i++ )
						{
							if ( yytoks[yy_i].t_val
								== yychar )
							{
								break;
							}
						}
						printf( "token %s\n",
							yytoks[yy_i].t_name );
					}
				}
#endif /* YYDEBUG */
				if ( yychar == 0 )	/* reached EOF. quit */
					YYABORT;
				yychar = -1;
				goto yy_newstate;
			}
		}/* end if ( yy_n == 0 ) */
		/*
		** reduction by production yy_n
		** put stack tops, etc. so things right after switch
		*/
#if YYDEBUG
		/*
		** if debugging, print the string that is the user's
		** specification of the reduction which is just about
		** to be done.
		*/
		if ( yydebug )
			printf( "Reduce by (%d) \"%s\"\n",
				yy_n, yyreds[ yy_n ] );
#endif
		yytmp = yy_n;			/* value to switch over */
		yypvt = yy_pv;			/* $vars top of value stack */
		/*
		** Look in goto table for next state
		** Sorry about using yy_state here as temporary
		** register variable, but why not, if it works...
		** If yyr2[ yy_n ] doesn't have the low order bit
		** set, then there is no action to be done for
		** this reduction.  So, no saving & unsaving of
		** registers done.  The only difference between the
		** code just after the if and the body of the if is
		** the goto yy_stack in the body.  This way the test
		** can be made before the choice of what to do is needed.
		*/
		{
			/* length of production doubled with extra bit */
			register int yy_len = yyr2[ yy_n ];

			if ( !( yy_len & 01 ) )
			{
				yy_len >>= 1;
				yyval = ( yy_pv -= yy_len )[1];	/* $$ = $1 */
				yy_state = yypgo[ yy_n = yyr1[ yy_n ] ] +
					*( yy_ps -= yy_len ) + 1;
				if ( yy_state >= YYLAST ||
					yychk[ yy_state =
					yyact[ yy_state ] ] != -yy_n )
				{
					yy_state = yyact[ yypgo[ yy_n ] ];
				}
				goto yy_stack;
			}
			yy_len >>= 1;
			yyval = ( yy_pv -= yy_len )[1];	/* $$ = $1 */
			yy_state = yypgo[ yy_n = yyr1[ yy_n ] ] +
				*( yy_ps -= yy_len ) + 1;
			if ( yy_state >= YYLAST ||
				yychk[ yy_state = yyact[ yy_state ] ] != -yy_n )
			{
				yy_state = yyact[ yypgo[ yy_n ] ];
			}
		}
					/* save until reenter driver code */
		yystate = yy_state;
		yyps = yy_ps;
		yypv = yy_pv;
	}
	/*
	** code supplied by user is placed in this switch
	*/
	switch( yytmp )
	{
		
case 43:
# line 115 "svccfg.y"
{ semerr(gettext("Syntax error.\n")); } break;
case 44:
# line 118 "svccfg.y"
{
		semerr(gettext("Unknown command \"%s\".\n"), yypvt[-1].str);
		free(yypvt[-1].str);
	} break;
case 45:
# line 123 "svccfg.y"
{
		string_list_t *slp;
		void *cookie = NULL;

		semerr(gettext("Unknown command \"%s\".\n"), yypvt[-2].str);

		while ((slp = uu_list_teardown(yypvt[-1].uul, &cookie)) != NULL) {
			free(slp->str);
			free(slp);
		}

		uu_list_destroy(yypvt[-1].uul);
		free(yypvt[-2].str);
	} break;
case 46:
# line 139 "svccfg.y"
{
		lscf_validate(yypvt[-1].str);
		free(yypvt[-1].str);
	} break;
case 47:
# line 143 "svccfg.y"
{ lscf_validate_fmri(NULL); } break;
case 48:
# line 144 "svccfg.y"
{ synerr(SCC_VALIDATE); return(0); } break;
case 49:
# line 147 "svccfg.y"
{
		string_list_t *slp;
		void *cookie = NULL;

		if (engine_import(yypvt[-1].uul) == -2) {
			synerr(SCC_IMPORT);
			return(0);
		}

		while ((slp = uu_list_teardown(yypvt[-1].uul, &cookie)) != NULL) {
			free(slp->str);
			free(slp);
		}

		uu_list_destroy(yypvt[-1].uul);
	} break;
case 50:
# line 163 "svccfg.y"
{ synerr(SCC_IMPORT); return(0); } break;
case 51:
# line 166 "svccfg.y"
{ 
		engine_cleanup(0);
	} break;
case 52:
# line 170 "svccfg.y"
{
		if (strcmp(yypvt[-1].str, "-a") == 0) {
			engine_cleanup(1);
			free(yypvt[-1].str);
		} else {
			synerr(SCC_CLEANUP);
			free(yypvt[-1].str);
			return (0);
		}
	} break;
case 53:
# line 180 "svccfg.y"
{ synerr(SCC_CLEANUP); return(0); } break;
case 54:
# line 184 "svccfg.y"
{
		lscf_service_export(yypvt[-1].str, NULL, 0);
		free(yypvt[-1].str);
	} break;
case 55:
# line 189 "svccfg.y"
{
		lscf_service_export(yypvt[-3].str, yypvt[-1].str, 0);
		free(yypvt[-3].str);
		free(yypvt[-1].str);
	} break;
case 56:
# line 195 "svccfg.y"
{
		if (strcmp(yypvt[-2].str, "-a") == 0) {
			lscf_service_export(yypvt[-1].str, NULL, SCE_ALL_VALUES);
			free(yypvt[-2].str);
			free(yypvt[-1].str);
		} else {
			synerr(SCC_EXPORT);
			free(yypvt[-2].str);
			free(yypvt[-1].str);
			return (0);
		}
	} break;
case 57:
# line 208 "svccfg.y"
{
		if (strcmp(yypvt[-4].str, "-a") == 0) {
			lscf_service_export(yypvt[-3].str, yypvt[-1].str, SCE_ALL_VALUES);
			free(yypvt[-4].str);
			free(yypvt[-3].str);
			free(yypvt[-1].str);
		} else {
			synerr(SCC_EXPORT);
			free(yypvt[-4].str);
			free(yypvt[-3].str);
			free(yypvt[-1].str);
			return (0);
		}
	} break;
case 58:
# line 222 "svccfg.y"
{ synerr(SCC_EXPORT); return(0); } break;
case 59:
# line 225 "svccfg.y"
{
		lscf_archive(NULL, 0);
	} break;
case 60:
# line 229 "svccfg.y"
{
		if (strcmp(yypvt[-1].str, "-a") == 0) {
			lscf_archive(NULL, SCE_ALL_VALUES);
			free(yypvt[-1].str);
		} else {
			synerr(SCC_ARCHIVE);
			free(yypvt[-1].str);
			return (0);
		}
	} break;
case 61:
# line 240 "svccfg.y"
{
		lscf_archive(yypvt[-1].str, 0);
		free(yypvt[-1].str);
	} break;
case 62:
# line 245 "svccfg.y"
{
		if (strcmp(yypvt[-3].str, "-a") == 0) {
			lscf_archive(yypvt[-1].str, SCE_ALL_VALUES);
			free(yypvt[-3].str);
			free(yypvt[-1].str);
		} else {
			synerr(SCC_ARCHIVE);
			free(yypvt[-3].str);
			free(yypvt[-1].str);
			return (0);
		}
	} break;
case 63:
# line 257 "svccfg.y"
{ synerr(SCC_ARCHIVE); return(0); } break;
case 64:
# line 260 "svccfg.y"
{
		(void) engine_restore(yypvt[-1].str);
		free(yypvt[-1].str);
	} break;
case 65:
# line 264 "svccfg.y"
{ synerr(SCC_RESTORE); return(0); } break;
case 66:
# line 267 "svccfg.y"
{
		if (engine_apply(yypvt[-1].str, 1) == -1) {
			if ((est->sc_cmd_flags & (SC_CMD_IACTIVE|SC_CMD_DONT_EXIT)) == 0)
				exit(1);

			free(yypvt[-1].str);
			return (0);
		}

		free(yypvt[-1].str);
	} break;
case 67:
# line 279 "svccfg.y"
{
		if (strcmp(yypvt[-2].str, "-n") == 0) {
			(void) engine_apply(yypvt[-1].str, 0);
			free(yypvt[-2].str);
			free(yypvt[-1].str);
		} else {
			synerr(SCC_APPLY);
			free(yypvt[-2].str);
			free(yypvt[-1].str);
			return (0);
		}
	} break;
case 68:
# line 291 "svccfg.y"
{ synerr(SCC_APPLY); return(0); } break;
case 69:
# line 293 "svccfg.y"
{ lscf_profile_extract(NULL); } break;
case 70:
# line 295 "svccfg.y"
{
		lscf_profile_extract(yypvt[-1].str);
		free(yypvt[-1].str);
	} break;
case 71:
# line 299 "svccfg.y"
{ synerr(SCC_EXTRACT); return(0); } break;
case 72:
# line 302 "svccfg.y"
{
		if (strcmp(yypvt[-1].str, "-f") == 0) {
			synerr(SCC_REPOSITORY);
			return(0);
		}
		lscf_set_repository(yypvt[-1].str, 0);
		free(yypvt[-1].str);
	} break;
case 73:
# line 311 "svccfg.y"
{
		if (strcmp(yypvt[-2].str, "-f") == 0) {
			lscf_set_repository(yypvt[-1].str, 1);
			free(yypvt[-2].str);
			free(yypvt[-1].str);
		} else {
			synerr(SCC_REPOSITORY);
			return(0);
		}
	} break;
case 74:
# line 321 "svccfg.y"
{ synerr(SCC_REPOSITORY); return(0); } break;
case 75:
# line 324 "svccfg.y"
{ lxml_inventory(yypvt[-1].str); free(yypvt[-1].str); } break;
case 76:
# line 325 "svccfg.y"
{ synerr(SCC_INVENTORY); return(0); } break;
case 77:
# line 328 "svccfg.y"
{
		string_list_t *slp;
		void *cookie = NULL;

		(void) engine_set(yypvt[-1].uul);

		while ((slp = uu_list_teardown(yypvt[-1].uul, &cookie)) != NULL) {
			free(slp->str);
			free(slp);
		}

		uu_list_destroy(yypvt[-1].uul);
	} break;
case 78:
# line 341 "svccfg.y"
{ synerr(SCC_SET); return(0); } break;
case 79:
# line 343 "svccfg.y"
{ exit(0); } break;
case 80:
# line 344 "svccfg.y"
{ synerr (SCC_END); return(0); } break;
case 81:
# line 346 "svccfg.y"
{ help(0); } break;
case 82:
# line 347 "svccfg.y"
{ help(yypvt[-1].tok); } break;
case 83:
# line 348 "svccfg.y"
{ synerr(SCC_HELP); return(0); } break;
case 84:
# line 350 "svccfg.y"
{ lscf_list(yypvt[-1].str); free(yypvt[-1].str); } break;
case 85:
# line 351 "svccfg.y"
{ synerr(SCC_LIST); return(0); } break;
case 86:
# line 353 "svccfg.y"
{ lscf_add(yypvt[-1].str); free(yypvt[-1].str); } break;
case 87:
# line 354 "svccfg.y"
{ synerr(SCC_ADD); return(0); } break;
case 88:
# line 357 "svccfg.y"
{ lscf_delete(yypvt[-1].str, 0); free(yypvt[-1].str); } break;
case 89:
# line 359 "svccfg.y"
{
		if (strcmp(yypvt[-2].str, "-f") == 0) {
			lscf_delete(yypvt[-1].str, 1);
			free(yypvt[-2].str);
			free(yypvt[-1].str);
		} else {
			synerr(SCC_DELETE);
			free(yypvt[-2].str);
			free(yypvt[-1].str);
			return(0);
		}
	} break;
case 90:
# line 371 "svccfg.y"
{ synerr(SCC_DELETE); return(0); } break;
case 91:
# line 373 "svccfg.y"
{ lscf_select(yypvt[-1].str); free(yypvt[-1].str); } break;
case 92:
# line 374 "svccfg.y"
{ synerr(SCC_SELECT); return(0) ;} break;
case 93:
# line 376 "svccfg.y"
{ lscf_unselect(); } break;
case 94:
# line 377 "svccfg.y"
{ synerr(SCC_UNSELECT); return(0); } break;
case 95:
# line 380 "svccfg.y"
{ lscf_listpg(yypvt[-1].str); free(yypvt[-1].str); } break;
case 96:
# line 381 "svccfg.y"
{ synerr(SCC_LISTPG); return(0); } break;
case 97:
# line 384 "svccfg.y"
{
		(void) lscf_addpg(yypvt[-3].str, yypvt[-2].str, yypvt[-1].str);
		free(yypvt[-3].str);
		free(yypvt[-2].str);
		free(yypvt[-1].str);
	} break;
case 98:
# line 390 "svccfg.y"
{ synerr(SCC_ADDPG); return(0); } break;
case 99:
# line 393 "svccfg.y"
{ lscf_delpg(yypvt[-1].str); free(yypvt[-1].str); } break;
case 100:
# line 394 "svccfg.y"
{ synerr(SCC_DELPG); return(0); } break;
case 101:
# line 397 "svccfg.y"
{
		lscf_delhash(yypvt[-1].str, 0); free(yypvt[-1].str);
	} break;
case 102:
# line 401 "svccfg.y"
{
		if (strcmp(yypvt[-2].str, "-d") == 0) {
			lscf_delhash(yypvt[-1].str, 1);
			free(yypvt[-2].str);
			free(yypvt[-1].str);
		} else {
			synerr(SCC_DELHASH);
			free(yypvt[-2].str);
			free(yypvt[-1].str);
			return(0);
		}
	} break;
case 103:
# line 413 "svccfg.y"
{ synerr(SCC_DELHASH); return(0); } break;
case 104:
# line 416 "svccfg.y"
{ lscf_listprop(yypvt[-1].str); free(yypvt[-1].str); } break;
case 105:
# line 417 "svccfg.y"
{ synerr(SCC_LISTPROP); return(0); } break;
case 106:
# line 420 "svccfg.y"
{
		lscf_setprop(yypvt[-3].str, NULL, yypvt[-1].str, NULL);
		free(yypvt[-3].str);
		free(yypvt[-1].str);
	} break;
case 107:
# line 426 "svccfg.y"
{
		(void) lscf_setprop(yypvt[-4].str, yypvt[-2].str, yypvt[-1].str, NULL);
		free(yypvt[-4].str);
		free(yypvt[-2].str);
		free(yypvt[-1].str);
	} break;
case 108:
# line 434 "svccfg.y"
{
		string_list_t *slp;
		void *cookie = NULL;

		(void) lscf_setprop(yypvt[-6].str, yypvt[-4].str, NULL, yypvt[-2].uul);

		free(yypvt[-6].str);
		free(yypvt[-4].str);

		while ((slp = uu_list_teardown(yypvt[-2].uul, &cookie)) != NULL) {
			free(slp->str);
			free(slp);
		}

		uu_list_destroy(yypvt[-2].uul);
	} break;
case 109:
# line 450 "svccfg.y"
{ synerr(SCC_SETPROP); return(0); } break;
case 110:
# line 451 "svccfg.y"
{ synerr(SCC_SETPROP); return(0); } break;
case 111:
# line 454 "svccfg.y"
{ lscf_delprop(yypvt[-1].str); free(yypvt[-1].str); } break;
case 112:
# line 455 "svccfg.y"
{ synerr(SCC_DELPROP); return(0); } break;
case 113:
# line 457 "svccfg.y"
{ lscf_editprop(); } break;
case 114:
# line 458 "svccfg.y"
{ synerr(SCC_EDITPROP); return(0); } break;
case 115:
# line 461 "svccfg.y"
{
		string_list_t *slp;
		void *cookie = NULL;

		if (lscf_describe(yypvt[-1].uul, 1) == -2) {
			synerr(SCC_DESCRIBE);
			return(0);
		}

		while ((slp = uu_list_teardown(yypvt[-1].uul, &cookie)) != NULL) {
			free(slp->str);
			free(slp);
		}

		uu_list_destroy(yypvt[-1].uul);
	} break;
case 116:
# line 477 "svccfg.y"
{ lscf_describe(NULL, 0); } break;
case 117:
# line 478 "svccfg.y"
{ synerr(SCC_DESCRIBE); return(0); } break;
case 118:
# line 481 "svccfg.y"
{
		lscf_addpropvalue(yypvt[-2].str, NULL, yypvt[-1].str);
		free(yypvt[-2].str);
		free(yypvt[-1].str);
	} break;
case 119:
# line 487 "svccfg.y"
{
		(void) lscf_addpropvalue(yypvt[-3].str, yypvt[-2].str, yypvt[-1].str);
		free(yypvt[-3].str);
		free(yypvt[-2].str);
		free(yypvt[-1].str);
	} break;
case 120:
# line 493 "svccfg.y"
{ synerr(SCC_ADDPROPVALUE); return(0); } break;
case 121:
# line 496 "svccfg.y"
{
		lscf_delpropvalue(yypvt[-2].str, yypvt[-1].str, 0);
		free(yypvt[-2].str);
		free(yypvt[-1].str);
	} break;
case 122:
# line 501 "svccfg.y"
{ synerr(SCC_DELPROPVALUE); return(0); } break;
case 123:
# line 504 "svccfg.y"
{
		string_list_t *slp;
		void *cookie = NULL;

		if (lscf_setenv(yypvt[-1].uul, 0) == -2) {
			synerr(SCC_SETENV);
			return(0);
		}

		while ((slp = uu_list_teardown(yypvt[-1].uul, &cookie)) != NULL) {
			free(slp->str);
			free(slp);
		}

		uu_list_destroy(yypvt[-1].uul);
	} break;
case 124:
# line 520 "svccfg.y"
{ synerr(SCC_SETENV); return(0); } break;
case 125:
# line 523 "svccfg.y"
{
		string_list_t *slp;
		void *cookie = NULL;

		if (lscf_setenv(yypvt[-1].uul, 1) == -2) {
			synerr(SCC_UNSETENV);
			return(0);
		}

		while ((slp = uu_list_teardown(yypvt[-1].uul, &cookie)) != NULL) {
			free(slp->str);
			free(slp);
		}

		uu_list_destroy(yypvt[-1].uul);
	} break;
case 126:
# line 539 "svccfg.y"
{ synerr(SCC_UNSETENV); return(0); } break;
case 127:
# line 541 "svccfg.y"
{ lscf_listsnap(); } break;
case 128:
# line 542 "svccfg.y"
{ synerr(SCC_LISTSNAP); return(0); } break;
case 129:
# line 545 "svccfg.y"
{ lscf_selectsnap(yypvt[-1].str); free(yypvt[-1].str); } break;
case 130:
# line 547 "svccfg.y"
{ synerr(SCC_SELECTSNAP); return(0); } break;
case 131:
# line 549 "svccfg.y"
{ lscf_revert(yypvt[-1].str); free (yypvt[-1].str); } break;
case 132:
# line 550 "svccfg.y"
{ synerr(SCC_REVERT); return(0); } break;
case 133:
# line 552 "svccfg.y"
{ lscf_refresh(); } break;
case 134:
# line 553 "svccfg.y"
{ synerr(SCC_REFRESH); return(0); } break;
case 135:
# line 556 "svccfg.y"
{
		lscf_delnotify(yypvt[-1].str, 0);
		free(yypvt[-1].str);
	} break;
case 136:
# line 561 "svccfg.y"
{
		if (strcmp(yypvt[-2].str, "-g") == 0) {
			lscf_delnotify(yypvt[-1].str, 1);
			free(yypvt[-2].str);
			free(yypvt[-1].str);
		} else {
			synerr(SCC_DELNOTIFY);
			free(yypvt[-2].str);
			free(yypvt[-1].str);
			return(0);
		}
	} break;
case 137:
# line 573 "svccfg.y"
{ synerr(SCC_DELNOTIFY); return(0); } break;
case 138:
# line 576 "svccfg.y"
{
		lscf_listnotify("all", 0);
	} break;
case 139:
# line 580 "svccfg.y"
{
		if (strcmp(yypvt[-1].str, "-g") == 0) {
			lscf_listnotify("all", 1);
		} else {
			lscf_listnotify(yypvt[-1].str, 0);
		}
		free(yypvt[-1].str);
	} break;
case 140:
# line 589 "svccfg.y"
{
		if (strcmp(yypvt[-2].str, "-g") == 0) {
			lscf_listnotify(yypvt[-1].str, 1);
			free(yypvt[-2].str);
			free(yypvt[-1].str);
		} else {
			synerr(SCC_LISTNOTIFY);
			free(yypvt[-2].str);
			free(yypvt[-1].str);
			return(0);
		}
	} break;
case 141:
# line 601 "svccfg.y"
{ synerr(SCC_LISTNOTIFY); return(0); } break;
case 142:
# line 604 "svccfg.y"
{
		string_list_t *slp;
		void *cookie = NULL;

		if (lscf_setnotify(yypvt[-1].uul) == -2)
			synerr(SCC_SETNOTIFY);

		while ((slp = uu_list_teardown(yypvt[-1].uul, &cookie)) != NULL) {
			free(slp->str);
			free(slp);
		}

		uu_list_destroy(yypvt[-1].uul);
	} break;
case 143:
# line 618 "svccfg.y"
{ synerr(SCC_SETNOTIFY); return(0); } break;
case 145:
# line 623 "svccfg.y"
{
		yyval.uul = uu_list_create(string_pool, NULL, 0);
		if (yyval.uul == NULL)
			uu_die(gettext("Out of memory\n"));
	} break;
case 146:
# line 629 "svccfg.y"
{
		string_list_t *slp;

		slp = safe_malloc(sizeof (*slp));

		slp->str = yypvt[-0].str;
		uu_list_node_init(slp, &slp->node, string_pool);
		uu_list_append(yypvt[-1].uul, slp);
		yyval.uul = yypvt[-1].uul;
	} break;
case 147:
# line 641 "svccfg.y"
{
		yyval.uul = yypvt[-0].uul;
	} break;
case 148:
# line 645 "svccfg.y"
{
		void *cookie = NULL;
		string_list_t *slp;

		/* Append $3 to $1. */
		while ((slp = uu_list_teardown(yypvt[-0].uul, &cookie)) != NULL)
			uu_list_append(yypvt[-2].uul, slp);

		uu_list_destroy(yypvt[-0].uul);
	} break;
case 149:
# line 656 "svccfg.y"
{ yyval.str = yypvt[-0].str; } break;
case 150:
# line 657 "svccfg.y"
{ yyval.str = yypvt[-0].str; } break;
case 151:
# line 659 "svccfg.y"
{ yyval.str = NULL; } break;
case 152:
# line 660 "svccfg.y"
{ yyval.str = yypvt[-0].str; } break;
case 153:
# line 662 "svccfg.y"
{ yyval.tok = SCC_VALIDATE; } break;
case 154:
# line 663 "svccfg.y"
{ yyval.tok = SCC_IMPORT; } break;
case 155:
# line 664 "svccfg.y"
{ yyval.tok = SCC_CLEANUP; } break;
case 156:
# line 665 "svccfg.y"
{ yyval.tok = SCC_EXPORT; } break;
case 157:
# line 666 "svccfg.y"
{ yyval.tok = SCC_APPLY; } break;
case 158:
# line 667 "svccfg.y"
{ yyval.tok = SCC_EXTRACT; } break;
case 159:
# line 668 "svccfg.y"
{ yyval.tok = SCC_REPOSITORY; } break;
case 160:
# line 669 "svccfg.y"
{ yyval.tok = SCC_ARCHIVE; } break;
case 161:
# line 670 "svccfg.y"
{ yyval.tok = SCC_INVENTORY; } break;
case 162:
# line 671 "svccfg.y"
{ yyval.tok = SCC_SET; } break;
case 163:
# line 672 "svccfg.y"
{ yyval.tok = SCC_END; } break;
case 164:
# line 673 "svccfg.y"
{ yyval.tok = SCC_HELP; } break;
case 165:
# line 674 "svccfg.y"
{ yyval.tok = SCC_LIST; } break;
case 166:
# line 675 "svccfg.y"
{ yyval.tok = SCC_ADD; } break;
case 167:
# line 676 "svccfg.y"
{ yyval.tok = SCC_DELETE; } break;
case 168:
# line 677 "svccfg.y"
{ yyval.tok = SCC_SELECT; } break;
case 169:
# line 678 "svccfg.y"
{ yyval.tok = SCC_UNSELECT; } break;
case 170:
# line 679 "svccfg.y"
{ yyval.tok = SCC_LISTPG; } break;
case 171:
# line 680 "svccfg.y"
{ yyval.tok = SCC_ADDPG; } break;
case 172:
# line 681 "svccfg.y"
{ yyval.tok = SCC_DELPG; } break;
case 173:
# line 682 "svccfg.y"
{ yyval.tok = SCC_DELHASH; } break;
case 174:
# line 683 "svccfg.y"
{ yyval.tok = SCC_LISTPROP; } break;
case 175:
# line 684 "svccfg.y"
{ yyval.tok = SCC_SETPROP; } break;
case 176:
# line 685 "svccfg.y"
{ yyval.tok = SCC_DELPROP; } break;
case 177:
# line 686 "svccfg.y"
{ yyval.tok = SCC_EDITPROP; } break;
case 178:
# line 687 "svccfg.y"
{ yyval.tok = SCC_ADDPROPVALUE; } break;
case 179:
# line 688 "svccfg.y"
{ yyval.tok = SCC_DELPROPVALUE; } break;
case 180:
# line 689 "svccfg.y"
{ yyval.tok = SCC_SETENV; } break;
case 181:
# line 690 "svccfg.y"
{ yyval.tok = SCC_UNSETENV; } break;
case 182:
# line 691 "svccfg.y"
{ yyval.tok = SCC_LISTSNAP; } break;
case 183:
# line 692 "svccfg.y"
{ yyval.tok = SCC_SELECTSNAP; } break;
case 184:
# line 693 "svccfg.y"
{ yyval.tok = SCC_REVERT; } break;
case 185:
# line 694 "svccfg.y"
{ yyval.tok = SCC_REFRESH; } break;
case 186:
# line 695 "svccfg.y"
{ yyval.tok = SCC_DESCRIBE; } break;
case 187:
# line 696 "svccfg.y"
{ yyval.tok = SCC_DELNOTIFY; } break;
case 188:
# line 697 "svccfg.y"
{ yyval.tok = SCC_LISTNOTIFY; } break;
case 189:
# line 698 "svccfg.y"
{ yyval.tok = SCC_SETNOTIFY; } break;
# line	556 "/opt/local/bin/..//share/lib/ccs/yaccpar"
	}
	goto yystack;		/* reset registers in driver code */
}

