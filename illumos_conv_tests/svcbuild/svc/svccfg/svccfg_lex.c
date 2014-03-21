#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
# define U(x) x
# define NLSTATE yyprevious=YYNEWLINE
# define BEGIN yybgin = yysvec + 1 +
# define INITIAL 0
# define YYLERR yysvec
# define YYSTATE (yyestate-yysvec-1)
# define YYOPTIM 1
# ifndef YYLMAX 
# define YYLMAX BUFSIZ
# endif 
#ifndef __cplusplus
# define output(c) (void)putc(c,yyout)
#else
# define lex_output(c) (void)putc(c,yyout)
#endif

#if defined(__cplusplus) || defined(__STDC__)

#if defined(__cplusplus) && defined(__EXTERN_C__)
extern "C" {
#endif
	int yyback(int *, int);
	int yyinput(void);
	int yylook(void);
	void yyoutput(int);
	int yyracc(int);
	int yyreject(void);
	void yyunput(int);
	int yylex(void);
#ifdef YYLEX_E
	void yywoutput(wchar_t);
	wchar_t yywinput(void);
	void yywunput(wchar_t);
#endif
#ifndef yyless
	int yyless(int);
#endif
#ifndef yywrap
	int yywrap(void);
#endif
#ifdef LEXDEBUG
	void allprint(char);
	void sprint(char *);
#endif
#if defined(__cplusplus) && defined(__EXTERN_C__)
}
#endif

#ifdef __cplusplus
extern "C" {
#endif
	void exit(int);
#ifdef __cplusplus
}
#endif

#endif
# define unput(c) {yytchar= (c);if(yytchar=='\n')yylineno--;*yysptr++=yytchar;}
# define yymore() (yymorfg=1)
#ifndef __cplusplus
# define input() (((yytchar=yysptr>yysbuf?U(*--yysptr):getc(yyin))==10?(yylineno++,yytchar):yytchar)==EOF?0:yytchar)
#else
# define lex_input() (((yytchar=yysptr>yysbuf?U(*--yysptr):getc(yyin))==10?(yylineno++,yytchar):yytchar)==EOF?0:yytchar)
#endif
#define ECHO fprintf(yyout, "%s",yytext)
# define REJECT { nstr = yyreject(); goto yyfussy;}
int yyleng;
#define YYISARRAY
char yytext[YYLMAX];
int yymorfg;
extern char *yysptr, yysbuf[];
int yytchar;
FILE *yyin = {stdin}, *yyout = {stdout};
extern int yylineno;
struct yysvf { 
	struct yywork *yystoff;
	struct yysvf *yyother;
	int *yystops;};
struct yysvf *yyestate;
extern struct yysvf yysvec[], *yybgin;

# line 3 "svccfg.l"
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


# line 24 "svccfg.l"
/*
 * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
 */


#pragma error_messages(off, E_BLOCK_DECL_UNUSED)
#pragma error_messages(off, E_EQUALITY_NOT_ASSIGNMENT)
#pragma error_messages(off, E_FUNC_RET_MAYBE_IGNORED2)
#pragma error_messages(off, E_STMT_NOT_REACHED)

#include <libintl.h>
#include <string.h>

#include "svccfg.h"
#include "svccfg_grammar.h"


# line 40 "svccfg.l"
/*
 * We need to undefine lex's input, unput, and output macros so that references
 * to these call the functions we provide at the end of this source file,
 * instead of the default versions based on libc's stdio.
 */
#ifdef input
#undef input
#endif

#ifdef unput
#undef unput
#endif

#ifdef output
#undef output
#endif

static int input(void);
static void unput(int);
static void output(int);

int parens = 0;

extern int yyerror(const char *);


# line 67 "svccfg.l"
/*
 * Since command tokens are only valid at the beginning of the command (or
 * after help), we'll only return them in the INITIAL state, and report them
 * as SCV_WORDs afterwards.
 */
# define WORD 2

# line 74 "svccfg.l"
/*
 * The default value of lex for transitions is 2000 and it seems we reached it.
 * So we are bumping it up!
 */
# define YYNEWLINE 10
int yylex(){
int nstr; extern int yyprevious;
#ifdef __cplusplus
/* to avoid CC and lint complaining yyfussy not being used ...*/
static int __lex_hack = 0;
if (__lex_hack) goto yyfussy;
#endif
while((nstr = yylook()) >= 0)
yyfussy: switch(nstr){
case 0:
if(yywrap()) return(0); break;
case 1:

# line 81 "svccfg.l"
		;
break;
case 2:

# line 83 "svccfg.l"
{ BEGIN WORD; return (SCC_VALIDATE); }
break;
case 3:

# line 84 "svccfg.l"
	{ BEGIN WORD; return (SCC_IMPORT); }
break;
case 4:

# line 85 "svccfg.l"
{ BEGIN WORD; return (SCC_CLEANUP); }
break;
case 5:

# line 86 "svccfg.l"
	{ BEGIN WORD; return (SCC_EXPORT); }
break;
case 6:

# line 87 "svccfg.l"
{ BEGIN WORD; return (SCC_ARCHIVE); }
break;
case 7:

# line 88 "svccfg.l"
{ BEGIN WORD; return (SCC_RESTORE); }
break;
case 8:

# line 89 "svccfg.l"
	{ BEGIN WORD; return (SCC_APPLY); }
break;
case 9:

# line 90 "svccfg.l"
{ BEGIN WORD; return (SCC_EXTRACT); }
break;
case 10:

# line 91 "svccfg.l"
{ BEGIN WORD; return (SCC_REPOSITORY); }
break;
case 11:

# line 92 "svccfg.l"
{ BEGIN WORD; return (SCC_INVENTORY); }
break;
case 12:

# line 93 "svccfg.l"
	{ BEGIN WORD; return (SCC_SET); }
break;
case 13:

# line 94 "svccfg.l"
	{ BEGIN WORD; return (SCC_END); }
break;
case 14:

# line 95 "svccfg.l"
	{ BEGIN WORD; return (SCC_END); }
break;
case 15:

# line 96 "svccfg.l"
	{ BEGIN WORD; return (SCC_END); }
break;
case 16:

# line 97 "svccfg.l"
	{ return (SCC_HELP); }
break;
case 17:

# line 99 "svccfg.l"
	{ BEGIN WORD; return (SCC_LIST); }
break;
case 18:

# line 100 "svccfg.l"
	{ BEGIN WORD; return (SCC_ADD); }
break;
case 19:

# line 101 "svccfg.l"
	{ BEGIN WORD; return (SCC_DELETE); }
break;
case 20:

# line 102 "svccfg.l"
	{ BEGIN WORD; return (SCC_SELECT); }
break;
case 21:

# line 103 "svccfg.l"
{ BEGIN WORD; return (SCC_UNSELECT); }
break;
case 22:

# line 105 "svccfg.l"
	{ BEGIN WORD; return (SCC_LISTPG); }
break;
case 23:

# line 106 "svccfg.l"
	{ BEGIN WORD; return (SCC_ADDPG); }
break;
case 24:

# line 107 "svccfg.l"
	{ BEGIN WORD; return (SCC_DELPG); }
break;
case 25:

# line 108 "svccfg.l"
{ BEGIN WORD; return (SCC_DELHASH); }
break;
case 26:

# line 109 "svccfg.l"
{ BEGIN WORD; return (SCC_LISTPROP); }
break;
case 27:

# line 110 "svccfg.l"
{ BEGIN WORD; return (SCC_SETPROP); }
break;
case 28:

# line 111 "svccfg.l"
{ BEGIN WORD; return (SCC_DELPROP); }
break;
case 29:

# line 112 "svccfg.l"
{ BEGIN WORD; return (SCC_EDITPROP); }
break;
case 30:

# line 113 "svccfg.l"
{ BEGIN WORD; return (SCC_DESCRIBE); }
break;
case 31:

# line 114 "svccfg.l"
{ BEGIN WORD; return (SCC_ADDPROPVALUE); }
break;
case 32:

# line 115 "svccfg.l"
{ BEGIN WORD; return (SCC_DELPROPVALUE); }
break;
case 33:

# line 116 "svccfg.l"
	{ BEGIN WORD; return (SCC_SETENV); }
break;
case 34:

# line 117 "svccfg.l"
{ BEGIN WORD; return (SCC_UNSETENV); }
break;
case 35:

# line 119 "svccfg.l"
{ BEGIN WORD; return (SCC_LISTSNAP); }
break;
case 36:

# line 120 "svccfg.l"
{ BEGIN WORD; return (SCC_SELECTSNAP); }
break;
case 37:

# line 121 "svccfg.l"
	{ BEGIN WORD; return (SCC_REVERT); }
break;
case 38:

# line 122 "svccfg.l"
{ BEGIN WORD; return (SCC_REFRESH); }
break;
case 39:

# line 124 "svccfg.l"
{ BEGIN WORD; return (SCC_DELNOTIFY); }
break;
case 40:

# line 125 "svccfg.l"
{ BEGIN WORD; return (SCC_LISTNOTIFY); }
break;
case 41:

# line 126 "svccfg.l"
{ BEGIN WORD; return (SCC_SETNOTIFY); }
break;
case 42:

# line 128 "svccfg.l"
	{
				if ((yylval.str = strdup(yytext)) == NULL) {
					yyerror(gettext("Out of memory"));
					exit(UU_EXIT_FATAL);
				}

				return SCV_WORD;
			}
break;
case 43:

# line 137 "svccfg.l"
{
				/*
				 * double-quoted strings start at a
				 * double-quote, include characters other than
				 * double-quote and backslash, and
				 * backslashed-characters, and end with a
				 * double-quote.
				 */

				char *str, *cp;
				int shift;

				if ((str = strdup(yytext)) == NULL) {
					yyerror(gettext("Out of memory"));
					exit(UU_EXIT_FATAL);
				}

				/* Strip out the backslashes. */
				for (cp = str, shift = 0; *cp != '\0'; ++cp) {
					if (*cp == '\\') {
						++cp;

						/*
						 * This can't be null because
						 * the string always ends with
						 * a double-quote.
						 */

						++shift;
						*(cp - shift) = *cp;
					} else if (shift != 0)
						*(cp - shift) = *cp;
				}

				/* Nullify everything after trailing quote */
				*(cp - shift) = '\0';

				yylval.str = str;
				return SCV_STRING;
			}
break;
case 44:

# line 178 "svccfg.l"
		{
				est->sc_cmd_lineno++;
				BEGIN INITIAL;
				return (SCS_NEWLINE);
			}
break;
case 45:

# line 184 "svccfg.l"
		;
break;
case 46:

# line 186 "svccfg.l"
		{ return SCS_REDIRECT; }
break;
case 47:

# line 187 "svccfg.l"
		{ return SCS_EQUALS; }
break;
case 48:

# line 188 "svccfg.l"
		{ ++parens; return SCS_LPAREN; }
break;
case 49:

# line 189 "svccfg.l"
		{ --parens; return SCS_RPAREN; }
break;
case 50:

# line 191 "svccfg.l"
		{
				uu_die(gettext("unrecognized character %s\n"),
				    yytext);
			}
break;
case -1:
break;
default:
(void)fprintf(yyout,"bad switch yylook %d",nstr);
} return(0); }
/* end of yylex */

# line 197 "svccfg.l"

int
yyerror(const char *s)
{
	return (0);
}

static int
input(void)
{
	static int saw_eof = 0;

	int c = engine_cmd_getc(est);

	/*
	 * To ensure input is terminated, slip in a newline on EOF.
	 */
	if (c == EOF) {
		if (saw_eof)
			return (0);

		saw_eof = 1;
		return ('\n');
	} else
		saw_eof = 0;

	if (c == '\n')
		yylineno++;

	return (c);
}

static void
unput(int c)
{
	if (c == '\n')
		yylineno--;

	(void) engine_cmd_ungetc(est, c == 0 ? EOF : c);
}

static void
output(int c)
{
	char ch = c;
	engine_cmd_nputs(est, &ch, sizeof (ch));
}
int yyvstop[] = {
0,

42,
50,
0, 

45,
50,
0, 

44,
0, 

50,
0, 

42,
50,
-1,
0, 

48,
50,
0, 

49,
50,
0, 

47,
50,
0, 

46,
50,
0, 

42,
50,
0, 

42,
50,
0, 

42,
50,
0, 

42,
50,
0, 

42,
50,
0, 

42,
50,
0, 

42,
50,
0, 

42,
50,
0, 

42,
50,
0, 

42,
50,
0, 

42,
50,
0, 

42,
50,
0, 

42,
0, 

45,
0, 

43,
0, 

42,
-1,
0, 

-1,
0, 

1,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

18,
42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

13,
42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

12,
42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

14,
42,
0, 

42,
0, 

42,
0, 

16,
42,
0, 

42,
0, 

42,
0, 

17,
42,
0, 

15,
42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

23,
42,
0, 

42,
0, 

8,
42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

24,
42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

19,
42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

5,
42,
0, 

42,
0, 

3,
42,
0, 

42,
0, 

42,
0, 

22,
42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

37,
42,
0, 

20,
42,
0, 

33,
42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

6,
42,
0, 

4,
42,
0, 

25,
42,
0, 

42,
0, 

28,
42,
0, 

42,
0, 

42,
0, 

9,
42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

38,
42,
0, 

42,
0, 

7,
42,
0, 

42,
0, 

42,
0, 

27,
42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

42,
0, 

30,
42,
0, 

29,
42,
0, 

42,
0, 

42,
0, 

26,
42,
0, 

35,
42,
0, 

42,
0, 

42,
0, 

42,
0, 

21,
42,
0, 

34,
42,
0, 

2,
42,
0, 

42,
0, 

39,
42,
0, 

42,
0, 

11,
42,
0, 

42,
0, 

42,
0, 

42,
0, 

41,
42,
0, 

42,
0, 

42,
0, 

40,
42,
0, 

10,
42,
0, 

36,
42,
0, 

42,
0, 

42,
0, 

31,
42,
0, 

32,
42,
0, 
0};
# define YYTYPE unsigned char
struct yywork { YYTYPE verify, advance; } yycrank[] = {
0,0,	0,0,	1,5,	32,32,	
0,0,	3,5,	0,0,	0,0,	
0,0,	0,0,	1,6,	1,7,	
0,0,	3,6,	3,7,	0,0,	
0,0,	5,26,	0,0,	0,0,	
8,28,	0,0,	9,31,	6,27,	
0,0,	5,0,	5,0,	0,0,	
8,28,	8,28,	9,32,	9,33,	
0,0,	0,0,	0,0,	1,8,	
1,9,	0,0,	3,8,	3,9,	
0,0,	1,10,	1,11,	4,9,	
3,10,	3,11,	6,27,	0,0,	
5,0,	4,11,	5,0,	20,0,	
20,0,	8,29,	0,0,	9,32,	
5,0,	5,0,	2,9,	8,28,	
0,0,	9,32,	1,12,	1,13,	
2,11,	3,12,	3,13,	30,0,	
0,0,	4,12,	4,13,	0,0,	
0,0,	0,0,	20,0,	0,0,	
20,0,	5,0,	5,0,	0,0,	
0,0,	0,0,	20,0,	20,0,	
2,12,	2,13,	0,0,	0,0,	
0,0,	0,0,	0,0,	30,28,	
0,0,	1,5,	32,32,	0,0,	
3,5,	0,0,	1,14,	0,0,	
1,15,	1,16,	1,17,	20,0,	
20,0,	1,18,	1,19,	0,0,	
5,26,	1,20,	0,0,	8,30,	
0,0,	9,31,	1,21,	1,22,	
1,23,	14,26,	1,24,	1,25,	
2,14,	0,0,	2,15,	2,16,	
2,17,	14,0,	14,0,	2,18,	
2,19,	16,0,	16,0,	2,20,	
0,0,	0,0,	0,0,	0,0,	
2,21,	2,22,	2,23,	0,0,	
2,24,	2,25,	15,0,	15,0,	
0,0,	0,0,	0,0,	20,45,	
14,0,	30,28,	14,0,	0,0,	
16,0,	0,0,	16,0,	0,0,	
14,0,	14,0,	0,0,	0,0,	
16,0,	16,0,	0,0,	0,0,	
0,0,	15,0,	0,0,	15,0,	
0,0,	0,0,	0,0,	17,26,	
0,0,	15,0,	15,0,	0,0,	
0,0,	14,0,	14,0,	17,0,	
17,0,	16,0,	16,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
18,0,	18,0,	15,0,	15,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	17,0,	0,0,	
17,0,	0,0,	0,0,	0,0,	
14,26,	0,0,	17,0,	17,0,	
0,0,	0,0,	0,0,	18,0,	
14,34,	18,0,	19,26,	0,0,	
0,0,	16,38,	0,0,	18,0,	
18,0,	0,0,	19,0,	19,0,	
14,35,	0,0,	14,36,	17,0,	
17,0,	0,0,	0,0,	0,0,	
21,0,	21,0,	0,0,	0,0,	
0,0,	15,37,	0,0,	0,0,	
18,0,	18,0,	0,0,	0,0,	
0,0,	19,0,	0,0,	19,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	19,0,	19,0,	21,0,	
0,0,	21,0,	17,26,	0,0,	
0,0,	0,0,	0,0,	21,0,	
21,0,	0,0,	17,39,	22,0,	
22,0,	0,0,	0,0,	0,0,	
23,0,	23,0,	19,0,	19,0,	
17,40,	24,0,	24,0,	0,0,	
18,42,	0,0,	0,0,	0,0,	
21,0,	21,0,	17,41,	0,0,	
0,0,	0,0,	22,0,	0,0,	
22,0,	0,0,	0,0,	23,0,	
0,0,	23,0,	22,0,	22,0,	
24,0,	0,0,	24,0,	23,0,	
23,0,	19,26,	0,0,	0,0,	
24,0,	24,0,	25,0,	25,0,	
0,0,	26,0,	26,0,	0,0,	
0,0,	0,0,	0,0,	22,0,	
22,0,	0,0,	19,43,	19,44,	
23,0,	23,0,	0,0,	0,0,	
0,0,	24,0,	24,0,	0,0,	
0,0,	25,0,	0,0,	25,0,	
26,0,	0,0,	26,0,	0,0,	
21,46,	25,0,	25,0,	0,0,	
26,0,	26,0,	0,0,	0,0,	
34,0,	34,0,	0,0,	35,0,	
35,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	22,47,	
0,0,	0,0,	25,0,	25,0,	
23,48,	26,0,	26,0,	0,0,	
0,0,	0,0,	0,0,	34,0,	
0,0,	34,0,	35,0,	0,0,	
35,0,	0,0,	24,49,	34,0,	
34,0,	0,0,	35,0,	35,0,	
36,0,	36,0,	0,0,	0,0,	
37,0,	37,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	25,50,	0,0,	
34,0,	34,0,	0,0,	35,0,	
35,0,	0,0,	0,0,	36,0,	
0,0,	36,0,	0,0,	37,0,	
0,0,	37,0,	0,0,	36,0,	
36,0,	38,26,	0,0,	37,0,	
37,0,	0,0,	0,0,	0,0,	
0,0,	38,0,	38,0,	0,0,	
0,0,	0,0,	39,0,	39,0,	
0,0,	0,0,	0,0,	0,0,	
36,0,	36,0,	0,0,	34,51,	
37,0,	37,0,	0,0,	0,0,	
40,0,	40,0,	0,0,	0,0,	
38,0,	0,0,	38,0,	0,0,	
0,0,	39,0,	35,52,	39,0,	
38,0,	38,0,	0,0,	0,0,	
0,0,	39,0,	39,0,	0,0,	
0,0,	0,0,	0,0,	40,0,	
0,0,	40,0,	42,0,	42,0,	
0,0,	0,0,	36,53,	40,0,	
40,0,	38,0,	38,0,	41,26,	
37,54,	0,0,	39,0,	39,0,	
43,0,	43,0,	0,0,	41,0,	
41,0,	0,0,	0,0,	0,0,	
0,0,	42,0,	0,0,	42,0,	
40,0,	40,0,	0,0,	0,0,	
0,0,	42,0,	42,0,	0,0,	
0,0,	0,0,	0,0,	43,0,	
38,26,	43,0,	41,0,	0,0,	
41,0,	0,0,	0,0,	43,0,	
43,0,	0,0,	41,0,	41,0,	
44,0,	44,0,	42,0,	42,0,	
38,55,	0,0,	39,57,	0,0,	
0,0,	0,0,	0,0,	38,56,	
45,0,	45,0,	0,0,	40,58,	
43,0,	43,0,	0,0,	41,0,	
41,0,	0,0,	0,0,	44,0,	
0,0,	44,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	44,0,	
44,0,	0,0,	0,0,	45,0,	
0,0,	45,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	45,0,	
45,0,	0,0,	46,0,	46,0,	
0,0,	42,62,	41,26,	0,0,	
44,0,	44,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	41,59,	
45,0,	45,0,	0,0,	43,63,	
0,0,	46,0,	41,60,	46,0,	
47,26,	0,0,	41,61,	48,26,	
0,0,	46,0,	46,0,	0,0,	
47,0,	47,0,	0,0,	48,0,	
48,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	49,0,	49,0,	
0,0,	0,0,	46,0,	46,0,	
0,0,	0,0,	0,0,	47,0,	
0,0,	47,0,	48,0,	0,0,	
48,0,	44,64,	0,0,	47,0,	
47,0,	0,0,	48,0,	48,0,	
0,0,	49,0,	45,65,	49,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	49,0,	49,0,	50,0,	
50,0,	0,0,	0,0,	0,0,	
47,0,	47,0,	0,0,	48,0,	
48,0,	0,0,	0,0,	51,0,	
51,0,	0,0,	46,66,	0,0,	
52,0,	52,0,	49,0,	49,0,	
0,0,	0,0,	50,0,	0,0,	
50,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	50,0,	50,0,	
0,0,	0,0,	51,0,	47,26,	
51,0,	0,0,	48,26,	52,0,	
0,0,	52,0,	51,0,	51,0,	
0,0,	47,67,	0,0,	52,0,	
52,0,	0,0,	0,0,	50,0,	
50,0,	0,0,	48,71,	47,68,	
53,0,	53,0,	47,69,	54,0,	
54,0,	47,70,	48,72,	51,0,	
51,0,	0,0,	55,26,	0,0,	
52,0,	52,0,	56,0,	56,0,	
49,73,	0,0,	55,0,	55,0,	
0,0,	0,0,	0,0,	53,0,	
0,0,	53,0,	54,0,	0,0,	
54,0,	0,0,	0,0,	53,0,	
53,0,	0,0,	54,0,	54,0,	
0,0,	56,0,	0,0,	56,0,	
0,0,	55,0,	50,74,	55,0,	
0,0,	56,0,	56,0,	0,0,	
0,0,	55,0,	55,0,	0,0,	
53,0,	53,0,	0,0,	54,0,	
54,0,	0,0,	51,75,	52,76,	
0,0,	0,0,	57,0,	57,0,	
0,0,	0,0,	56,0,	56,0,	
0,0,	0,0,	55,0,	55,0,	
0,0,	0,0,	58,0,	58,0,	
0,0,	59,0,	59,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	57,0,	0,0,	57,0,	
0,0,	0,0,	0,0,	54,78,	
0,0,	57,0,	57,0,	53,77,	
0,0,	58,0,	0,0,	58,0,	
59,0,	55,26,	59,0,	0,0,	
56,83,	58,0,	58,0,	0,0,	
59,0,	59,0,	55,79,	60,0,	
60,0,	55,80,	57,0,	57,0,	
0,0,	0,0,	0,0,	55,81,	
0,0,	55,82,	61,0,	61,0,	
0,0,	0,0,	58,0,	58,0,	
0,0,	59,0,	59,0,	0,0,	
0,0,	0,0,	60,0,	0,0,	
60,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	60,0,	60,0,	
0,0,	61,0,	0,0,	61,0,	
62,0,	62,0,	0,0,	0,0,	
0,0,	61,0,	61,0,	0,0,	
0,0,	0,0,	63,0,	63,0,	
0,0,	0,0,	0,0,	60,0,	
60,0,	0,0,	0,0,	0,0,	
0,0,	57,84,	0,0,	62,0,	
0,0,	62,0,	61,0,	61,0,	
0,0,	0,0,	0,0,	62,0,	
62,0,	63,0,	0,0,	63,0,	
59,85,	0,0,	0,0,	0,0,	
0,0,	63,0,	63,0,	64,0,	
64,0,	0,0,	65,0,	65,0,	
0,0,	0,0,	0,0,	0,0,	
62,0,	62,0,	0,0,	0,0,	
0,0,	66,0,	66,0,	0,0,	
0,0,	0,0,	63,0,	63,0,	
0,0,	60,86,	64,0,	0,0,	
64,0,	65,0,	0,0,	65,0,	
0,0,	0,0,	64,0,	64,0,	
0,0,	65,0,	65,0,	61,87,	
66,0,	0,0,	66,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
66,0,	66,0,	67,0,	67,0,	
0,0,	69,0,	69,0,	64,0,	
64,0,	0,0,	65,0,	65,0,	
0,0,	0,0,	0,0,	62,88,	
0,0,	68,0,	68,0,	0,0,	
0,0,	66,0,	66,0,	0,0,	
63,89,	67,0,	0,0,	67,0,	
69,0,	0,0,	69,0,	0,0,	
0,0,	67,0,	67,0,	0,0,	
69,0,	69,0,	0,0,	0,0,	
68,0,	0,0,	68,0,	70,0,	
70,0,	0,0,	0,0,	64,90,	
68,0,	68,0,	0,0,	0,0,	
0,0,	0,0,	67,0,	67,0,	
0,0,	69,0,	69,0,	0,0,	
0,0,	71,0,	71,0,	0,0,	
0,0,	65,91,	70,0,	0,0,	
70,0,	68,0,	68,0,	72,26,	
0,0,	0,0,	70,0,	70,0,	
66,92,	0,0,	0,0,	72,0,	
72,0,	0,0,	0,0,	0,0,	
71,0,	0,0,	71,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
71,0,	71,0,	0,0,	70,0,	
70,0,	73,0,	73,0,	0,0,	
0,0,	0,0,	72,0,	0,0,	
72,0,	0,0,	0,0,	67,93,	
0,0,	0,0,	72,0,	72,0,	
69,95,	71,0,	71,0,	74,0,	
74,0,	0,0,	0,0,	68,94,	
73,0,	0,0,	73,0,	0,0,	
0,0,	75,26,	0,0,	0,0,	
73,0,	73,0,	0,0,	72,0,	
72,0,	75,0,	75,0,	70,96,	
0,0,	0,0,	74,0,	0,0,	
74,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	74,0,	74,0,	
0,0,	73,0,	73,0,	0,0,	
0,0,	71,97,	0,0,	0,0,	
75,0,	0,0,	75,0,	0,0,	
0,0,	0,0,	72,26,	0,0,	
75,0,	75,0,	0,0,	74,0,	
74,0,	76,0,	76,0,	72,98,	
77,0,	77,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
72,99,	0,0,	72,100,	78,0,	
78,0,	75,0,	75,0,	79,0,	
79,0,	73,101,	0,0,	0,0,	
76,0,	0,0,	76,0,	77,0,	
0,0,	77,0,	0,0,	0,0,	
76,0,	76,0,	0,0,	77,0,	
77,0,	0,0,	78,0,	0,0,	
78,0,	0,0,	79,0,	74,102,	
79,0,	0,0,	78,0,	78,0,	
75,26,	0,0,	79,0,	79,0,	
0,0,	76,0,	76,0,	0,0,	
77,0,	77,0,	0,0,	75,103,	
0,0,	0,0,	80,0,	80,0,	
0,0,	81,0,	81,0,	78,0,	
78,0,	0,0,	75,104,	79,0,	
79,0,	0,0,	0,0,	0,0,	
82,0,	82,0,	0,0,	83,0,	
83,0,	0,0,	0,0,	0,0,	
0,0,	80,0,	0,0,	80,0,	
81,0,	0,0,	81,0,	0,0,	
0,0,	80,0,	80,0,	0,0,	
81,0,	81,0,	0,0,	82,0,	
77,106,	82,0,	83,0,	0,0,	
83,0,	0,0,	0,0,	82,0,	
82,0,	0,0,	83,0,	83,0,	
0,0,	76,105,	80,0,	80,0,	
78,107,	81,0,	81,0,	0,0,	
84,0,	84,0,	0,0,	85,0,	
85,0,	0,0,	79,108,	0,0,	
82,0,	82,0,	0,0,	83,0,	
83,0,	86,0,	86,0,	0,0,	
0,0,	87,0,	87,0,	0,0,	
0,0,	0,0,	0,0,	84,0,	
0,0,	84,0,	85,0,	0,0,	
85,0,	0,0,	80,109,	84,0,	
84,0,	0,0,	85,0,	85,0,	
86,0,	0,0,	86,0,	0,0,	
87,0,	0,0,	87,0,	0,0,	
86,0,	86,0,	0,0,	81,110,	
87,0,	87,0,	82,111,	0,0,	
84,0,	84,0,	0,0,	85,0,	
85,0,	88,0,	88,0,	0,0,	
0,0,	82,112,	89,0,	89,0,	
83,113,	86,0,	86,0,	90,0,	
90,0,	87,0,	87,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
88,0,	0,0,	88,0,	0,0,	
0,0,	89,0,	0,0,	89,0,	
88,0,	88,0,	90,0,	0,0,	
90,0,	89,0,	89,0,	0,0,	
0,0,	0,0,	90,0,	90,0,	
92,0,	92,0,	0,0,	84,114,	
91,26,	87,116,	0,0,	0,0,	
0,0,	88,0,	88,0,	0,0,	
91,0,	91,0,	89,0,	89,0,	
0,0,	0,0,	86,115,	90,0,	
90,0,	0,0,	0,0,	92,0,	
0,0,	92,0,	94,0,	94,0,	
0,0,	0,0,	0,0,	92,0,	
92,0,	0,0,	0,0,	91,0,	
0,0,	91,0,	93,0,	93,0,	
0,0,	0,0,	0,0,	91,0,	
91,0,	0,0,	0,0,	0,0,	
0,0,	94,0,	0,0,	94,0,	
92,0,	92,0,	0,0,	0,0,	
0,0,	94,0,	94,0,	0,0,	
0,0,	93,0,	0,0,	93,0,	
91,0,	91,0,	0,0,	89,117,	
90,118,	93,0,	93,0,	95,0,	
95,0,	0,0,	96,0,	96,0,	
0,0,	0,0,	94,0,	94,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	97,0,	97,0,	0,0,	
0,0,	0,0,	93,0,	93,0,	
0,0,	0,0,	95,0,	91,26,	
95,0,	96,0,	0,0,	96,0,	
0,0,	0,0,	95,0,	95,0,	
0,0,	96,0,	96,0,	0,0,	
97,0,	0,0,	97,0,	98,0,	
98,0,	91,119,	0,0,	91,120,	
97,0,	97,0,	91,121,	0,0,	
0,0,	0,0,	0,0,	95,0,	
95,0,	0,0,	96,0,	96,0,	
99,0,	99,0,	93,122,	0,0,	
94,123,	0,0,	98,0,	0,0,	
98,0,	97,0,	97,0,	0,0,	
0,0,	0,0,	98,0,	98,0,	
0,0,	100,0,	100,0,	0,0,	
0,0,	0,0,	0,0,	99,0,	
0,0,	99,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	99,0,	
99,0,	101,0,	101,0,	98,0,	
98,0,	0,0,	0,0,	0,0,	
100,0,	0,0,	100,0,	102,0,	
102,0,	95,124,	0,0,	97,126,	
100,0,	100,0,	0,0,	96,125,	
99,0,	99,0,	0,0,	0,0,	
101,0,	0,0,	101,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
101,0,	101,0,	102,0,	0,0,	
102,0,	100,0,	100,0,	0,0,	
0,0,	0,0,	102,0,	102,0,	
103,0,	103,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
98,127,	101,0,	101,0,	0,0,	
0,0,	104,0,	104,0,	0,0,	
105,0,	105,0,	0,0,	102,0,	
102,0,	0,0,	0,0,	103,0,	
0,0,	103,0,	99,128,	0,0,	
0,0,	0,0,	0,0,	103,0,	
103,0,	0,0,	0,0,	0,0,	
104,0,	0,0,	104,0,	105,0,	
0,0,	105,0,	0,0,	0,0,	
104,0,	104,0,	100,129,	105,0,	
105,0,	106,0,	106,0,	0,0,	
103,0,	103,0,	107,0,	107,0,	
101,130,	0,0,	102,132,	108,0,	
108,0,	0,0,	0,0,	0,0,	
101,131,	104,0,	104,0,	0,0,	
105,0,	105,0,	0,0,	0,0,	
106,0,	0,0,	106,0,	0,0,	
0,0,	107,0,	0,0,	107,0,	
106,0,	106,0,	108,0,	0,0,	
108,0,	107,0,	107,0,	0,0,	
0,0,	0,0,	108,0,	108,0,	
0,0,	109,0,	109,0,	0,0,	
110,0,	110,0,	0,0,	0,0,	
0,0,	106,0,	106,0,	0,0,	
0,0,	0,0,	107,0,	107,0,	
111,0,	111,0,	0,0,	108,0,	
108,0,	0,0,	0,0,	104,133,	
109,0,	0,0,	109,0,	110,0,	
0,0,	110,0,	0,0,	0,0,	
109,0,	109,0,	0,0,	110,0,	
110,0,	0,0,	0,0,	111,0,	
0,0,	111,0,	112,0,	112,0,	
0,0,	0,0,	0,0,	111,0,	
111,0,	0,0,	0,0,	0,0,	
0,0,	109,0,	109,0,	0,0,	
110,0,	110,0,	0,0,	108,136,	
113,0,	113,0,	0,0,	0,0,	
0,0,	112,0,	106,134,	112,0,	
111,0,	111,0,	107,135,	0,0,	
0,0,	112,0,	112,0,	0,0,	
0,0,	114,0,	114,0,	0,0,	
0,0,	0,0,	0,0,	113,0,	
0,0,	113,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	113,0,	
113,0,	0,0,	112,0,	112,0,	
115,0,	115,0,	0,0,	0,0,	
114,0,	0,0,	114,0,	0,0,	
0,0,	0,0,	0,0,	109,137,	
114,0,	114,0,	0,0,	110,138,	
113,0,	113,0,	116,0,	116,0,	
0,0,	0,0,	0,0,	115,0,	
0,0,	115,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	115,0,	
115,0,	114,0,	114,0,	0,0,	
117,0,	117,0,	0,0,	0,0,	
0,0,	116,0,	0,0,	116,0,	
0,0,	0,0,	0,0,	0,0,	
112,139,	116,0,	116,0,	0,0,	
115,0,	115,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	117,0,	
113,140,	117,0,	118,0,	118,0,	
0,0,	0,0,	0,0,	117,0,	
117,0,	0,0,	116,0,	116,0,	
119,0,	119,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	118,0,	114,141,	118,0,	
117,0,	117,0,	0,0,	0,0,	
0,0,	118,0,	118,0,	119,0,	
0,0,	119,0,	120,0,	120,0,	
0,0,	0,0,	0,0,	119,0,	
119,0,	0,0,	0,0,	115,142,	
116,143,	121,0,	121,0,	0,0,	
0,0,	0,0,	118,0,	118,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	120,0,	0,0,	120,0,	
119,0,	119,0,	0,0,	0,0,	
0,0,	120,0,	120,0,	0,0,	
121,0,	0,0,	121,0,	122,0,	
122,0,	0,0,	0,0,	0,0,	
121,0,	121,0,	0,0,	117,144,	
0,0,	0,0,	0,0,	123,0,	
123,0,	0,0,	120,0,	120,0,	
124,0,	124,0,	0,0,	0,0,	
0,0,	0,0,	122,0,	0,0,	
122,0,	121,0,	121,0,	0,0,	
0,0,	0,0,	122,0,	122,0,	
0,0,	118,145,	123,0,	0,0,	
123,0,	0,0,	119,146,	124,0,	
0,0,	124,0,	123,0,	123,0,	
0,0,	0,0,	0,0,	124,0,	
124,0,	0,0,	0,0,	122,0,	
122,0,	0,0,	0,0,	0,0,	
120,147,	125,0,	125,0,	0,0,	
126,0,	126,0,	0,0,	123,0,	
123,0,	0,0,	0,0,	120,148,	
124,0,	124,0,	127,0,	127,0,	
0,0,	0,0,	121,149,	0,0,	
0,0,	0,0,	0,0,	0,0,	
125,0,	0,0,	125,0,	126,0,	
0,0,	126,0,	0,0,	0,0,	
125,0,	125,0,	0,0,	126,0,	
126,0,	127,0,	0,0,	127,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	127,0,	127,0,	128,0,	
128,0,	122,150,	0,0,	123,151,	
0,0,	125,0,	125,0,	0,0,	
126,0,	126,0,	0,0,	0,0,	
129,0,	129,0,	0,0,	130,0,	
130,0,	124,152,	127,0,	127,0,	
0,0,	0,0,	128,0,	0,0,	
128,0,	131,0,	131,0,	0,0,	
0,0,	0,0,	128,0,	128,0,	
0,0,	0,0,	0,0,	129,0,	
0,0,	129,0,	130,0,	0,0,	
130,0,	0,0,	0,0,	129,0,	
129,0,	0,0,	130,0,	130,0,	
131,0,	0,0,	131,0,	128,0,	
128,0,	0,0,	0,0,	0,0,	
131,0,	131,0,	132,0,	132,0,	
125,153,	0,0,	0,0,	126,154,	
129,0,	129,0,	0,0,	130,0,	
130,0,	133,0,	133,0,	0,0,	
134,0,	134,0,	0,0,	127,155,	
0,0,	131,0,	131,0,	0,0,	
0,0,	132,0,	0,0,	132,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	132,0,	132,0,	0,0,	
133,0,	0,0,	133,0,	134,0,	
0,0,	134,0,	0,0,	0,0,	
133,0,	133,0,	0,0,	134,0,	
134,0,	0,0,	128,156,	130,158,	
135,0,	135,0,	132,0,	132,0,	
0,0,	0,0,	129,157,	0,0,	
0,0,	131,159,	136,0,	136,0,	
0,0,	133,0,	133,0,	0,0,	
134,0,	134,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	135,0,	
0,0,	135,0,	137,0,	137,0,	
0,0,	0,0,	0,0,	135,0,	
135,0,	136,0,	0,0,	136,0,	
138,0,	138,0,	132,160,	0,0,	
0,0,	136,0,	136,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	137,0,	0,0,	137,0,	
135,0,	135,0,	0,0,	0,0,	
134,162,	137,0,	137,0,	138,0,	
0,0,	138,0,	136,0,	136,0,	
133,161,	0,0,	0,0,	138,0,	
138,0,	0,0,	139,0,	139,0,	
0,0,	140,0,	140,0,	0,0,	
0,0,	0,0,	137,0,	137,0,	
0,0,	0,0,	0,0,	141,0,	
141,0,	0,0,	142,0,	142,0,	
138,0,	138,0,	0,0,	0,0,	
0,0,	139,0,	0,0,	139,0,	
140,0,	0,0,	140,0,	0,0,	
0,0,	139,0,	139,0,	135,163,	
140,0,	140,0,	141,0,	0,0,	
141,0,	142,0,	0,0,	142,0,	
0,0,	0,0,	141,0,	141,0,	
0,0,	142,0,	142,0,	143,0,	
143,0,	137,164,	139,0,	139,0,	
0,0,	140,0,	140,0,	0,0,	
0,0,	144,0,	144,0,	0,0,	
138,165,	0,0,	0,0,	141,0,	
141,0,	0,0,	142,0,	142,0,	
0,0,	0,0,	143,0,	0,0,	
143,0,	145,0,	145,0,	0,0,	
0,0,	0,0,	143,0,	143,0,	
144,0,	0,0,	144,0,	146,0,	
146,0,	0,0,	0,0,	0,0,	
144,0,	144,0,	140,167,	0,0,	
0,0,	0,0,	0,0,	0,0,	
145,0,	0,0,	145,0,	143,0,	
143,0,	139,166,	0,0,	0,0,	
145,0,	145,0,	146,0,	0,0,	
146,0,	144,0,	144,0,	0,0,	
0,0,	141,168,	146,0,	146,0,	
147,0,	147,0,	0,0,	148,0,	
148,0,	0,0,	0,0,	0,0,	
0,0,	145,0,	145,0,	0,0,	
0,0,	0,0,	149,0,	149,0,	
0,0,	150,0,	150,0,	146,0,	
146,0,	0,0,	0,0,	147,0,	
0,0,	147,0,	148,0,	0,0,	
148,0,	0,0,	0,0,	147,0,	
147,0,	0,0,	148,0,	148,0,	
0,0,	149,0,	143,169,	149,0,	
150,0,	0,0,	150,0,	0,0,	
0,0,	149,0,	149,0,	0,0,	
150,0,	150,0,	0,0,	0,0,	
147,0,	147,0,	0,0,	148,0,	
148,0,	151,0,	151,0,	145,170,	
0,0,	152,0,	152,0,	0,0,	
0,0,	0,0,	149,0,	149,0,	
0,0,	150,0,	150,0,	0,0,	
153,0,	153,0,	146,171,	154,0,	
154,0,	0,0,	0,0,	0,0,	
151,0,	0,0,	151,0,	0,0,	
152,0,	0,0,	152,0,	0,0,	
151,0,	151,0,	0,0,	0,0,	
152,0,	152,0,	0,0,	153,0,	
0,0,	153,0,	154,0,	0,0,	
154,0,	0,0,	149,173,	153,0,	
153,0,	148,172,	154,0,	154,0,	
0,0,	151,0,	151,0,	0,0,	
150,174,	152,0,	152,0,	155,0,	
155,0,	0,0,	156,0,	156,0,	
0,0,	0,0,	0,0,	0,0,	
153,0,	153,0,	0,0,	154,0,	
154,0,	0,0,	0,0,	157,0,	
157,0,	0,0,	158,0,	158,0,	
0,0,	0,0,	155,0,	0,0,	
155,0,	156,0,	0,0,	156,0,	
0,0,	0,0,	155,0,	155,0,	
0,0,	156,0,	156,0,	0,0,	
0,0,	152,176,	157,0,	0,0,	
157,0,	158,0,	0,0,	158,0,	
0,0,	0,0,	157,0,	157,0,	
151,175,	158,0,	158,0,	155,0,	
155,0,	0,0,	156,0,	156,0,	
0,0,	159,0,	159,0,	0,0,	
160,0,	160,0,	0,0,	0,0,	
0,0,	154,177,	0,0,	157,0,	
157,0,	0,0,	158,0,	158,0,	
161,0,	161,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
159,0,	0,0,	159,0,	160,0,	
0,0,	160,0,	0,0,	0,0,	
159,0,	159,0,	0,0,	160,0,	
160,0,	0,0,	0,0,	161,0,	
0,0,	161,0,	156,178,	0,0,	
0,0,	0,0,	0,0,	161,0,	
161,0,	0,0,	0,0,	0,0,	
158,180,	159,0,	159,0,	0,0,	
160,0,	160,0,	0,0,	0,0,	
162,0,	162,0,	157,179,	163,0,	
163,0,	0,0,	0,0,	0,0,	
161,0,	161,0,	0,0,	0,0,	
0,0,	0,0,	164,0,	164,0,	
0,0,	0,0,	165,0,	165,0,	
0,0,	0,0,	0,0,	162,0,	
0,0,	162,0,	163,0,	0,0,	
163,0,	0,0,	0,0,	162,0,	
162,0,	0,0,	163,0,	163,0,	
0,0,	164,0,	0,0,	164,0,	
0,0,	165,0,	159,181,	165,0,	
0,0,	164,0,	164,0,	0,0,	
0,0,	165,0,	165,0,	160,182,	
162,0,	162,0,	0,0,	163,0,	
163,0,	166,0,	166,0,	0,0,	
167,0,	167,0,	0,0,	0,0,	
0,0,	161,183,	164,0,	164,0,	
0,0,	0,0,	165,0,	165,0,	
168,0,	168,0,	0,0,	169,0,	
169,0,	0,0,	0,0,	0,0,	
166,0,	0,0,	166,0,	167,0,	
0,0,	167,0,	0,0,	0,0,	
166,0,	166,0,	0,0,	167,0,	
167,0,	0,0,	0,0,	168,0,	
0,0,	168,0,	169,0,	0,0,	
169,0,	0,0,	0,0,	168,0,	
168,0,	0,0,	169,0,	169,0,	
0,0,	166,0,	166,0,	165,184,	
167,0,	167,0,	0,0,	170,0,	
170,0,	0,0,	171,0,	171,0,	
0,0,	0,0,	0,0,	0,0,	
168,0,	168,0,	0,0,	169,0,	
169,0,	0,0,	172,0,	172,0,	
0,0,	173,0,	173,0,	0,0,	
0,0,	0,0,	170,0,	0,0,	
170,0,	171,0,	0,0,	171,0,	
0,0,	0,0,	170,0,	170,0,	
0,0,	171,0,	171,0,	0,0,	
167,186,	172,0,	0,0,	172,0,	
173,0,	0,0,	173,0,	0,0,	
0,0,	172,0,	172,0,	0,0,	
173,0,	173,0,	166,185,	170,0,	
170,0,	0,0,	171,0,	171,0,	
174,0,	174,0,	0,0,	168,187,	
175,0,	175,0,	0,0,	0,0,	
0,0,	0,0,	172,0,	172,0,	
0,0,	173,0,	173,0,	176,0,	
176,0,	0,0,	177,0,	177,0,	
0,0,	0,0,	0,0,	174,0,	
0,0,	174,0,	0,0,	175,0,	
0,0,	175,0,	0,0,	174,0,	
174,0,	0,0,	0,0,	175,0,	
175,0,	0,0,	176,0,	0,0,	
176,0,	177,0,	171,189,	177,0,	
0,0,	0,0,	176,0,	176,0,	
170,188,	177,0,	177,0,	0,0,	
174,0,	174,0,	0,0,	0,0,	
175,0,	175,0,	178,0,	178,0,	
0,0,	172,190,	179,0,	179,0,	
173,191,	0,0,	0,0,	176,0,	
176,0,	0,0,	177,0,	177,0,	
180,0,	180,0,	0,0,	0,0,	
181,0,	181,0,	0,0,	0,0,	
0,0,	178,0,	0,0,	178,0,	
0,0,	179,0,	0,0,	179,0,	
0,0,	178,0,	178,0,	0,0,	
0,0,	179,0,	179,0,	180,0,	
0,0,	180,0,	0,0,	181,0,	
0,0,	181,0,	0,0,	180,0,	
180,0,	0,0,	175,192,	181,0,	
181,0,	0,0,	178,0,	178,0,	
182,0,	182,0,	179,0,	179,0,	
0,0,	183,0,	183,0,	177,193,	
0,0,	0,0,	184,0,	184,0,	
180,0,	180,0,	0,0,	0,0,	
181,0,	181,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	182,0,	
0,0,	182,0,	0,0,	0,0,	
183,0,	0,0,	183,0,	182,0,	
182,0,	184,0,	0,0,	184,0,	
183,0,	183,0,	0,0,	178,194,	
0,0,	184,0,	184,0,	185,0,	
185,0,	0,0,	186,0,	186,0,	
0,0,	0,0,	0,0,	0,0,	
182,0,	182,0,	0,0,	0,0,	
0,0,	183,0,	183,0,	187,0,	
187,0,	0,0,	184,0,	184,0,	
0,0,	0,0,	185,0,	180,195,	
185,0,	186,0,	0,0,	186,0,	
0,0,	181,196,	185,0,	185,0,	
0,0,	186,0,	186,0,	0,0,	
0,0,	0,0,	187,0,	0,0,	
187,0,	188,0,	188,0,	0,0,	
0,0,	0,0,	187,0,	187,0,	
182,197,	183,198,	0,0,	185,0,	
185,0,	0,0,	186,0,	186,0,	
0,0,	189,0,	189,0,	0,0,	
190,0,	190,0,	0,0,	0,0,	
188,0,	0,0,	188,0,	187,0,	
187,0,	0,0,	0,0,	0,0,	
188,0,	188,0,	191,0,	191,0,	
0,0,	0,0,	184,199,	0,0,	
189,0,	0,0,	189,0,	190,0,	
0,0,	190,0,	0,0,	185,200,	
189,0,	189,0,	0,0,	190,0,	
190,0,	188,0,	188,0,	0,0,	
0,0,	191,0,	0,0,	191,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	191,0,	191,0,	192,0,	
192,0,	189,0,	189,0,	0,0,	
190,0,	190,0,	0,0,	0,0,	
0,0,	193,0,	193,0,	0,0,	
194,0,	194,0,	0,0,	0,0,	
0,0,	0,0,	191,0,	191,0,	
0,0,	0,0,	192,0,	0,0,	
192,0,	195,0,	195,0,	0,0,	
0,0,	0,0,	192,0,	192,0,	
193,0,	0,0,	193,0,	194,0,	
0,0,	194,0,	0,0,	0,0,	
193,0,	193,0,	189,202,	194,0,	
194,0,	188,201,	0,0,	0,0,	
195,0,	0,0,	195,0,	192,0,	
192,0,	0,0,	0,0,	0,0,	
195,0,	195,0,	196,0,	196,0,	
0,0,	193,0,	193,0,	0,0,	
194,0,	194,0,	0,0,	0,0,	
197,0,	197,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	195,0,	195,0,	0,0,	
0,0,	196,0,	0,0,	196,0,	
198,0,	198,0,	0,0,	0,0,	
0,0,	196,0,	196,0,	197,0,	
0,0,	197,0,	199,0,	199,0,	
0,0,	193,204,	0,0,	197,0,	
197,0,	0,0,	0,0,	0,0,	
192,203,	0,0,	0,0,	198,0,	
0,0,	198,0,	196,0,	196,0,	
0,0,	0,0,	0,0,	198,0,	
198,0,	199,0,	0,0,	199,0,	
197,0,	197,0,	0,0,	0,0,	
194,205,	199,0,	199,0,	200,0,	
200,0,	0,0,	0,0,	0,0,	
201,0,	201,0,	0,0,	0,0,	
198,0,	198,0,	0,0,	0,0,	
0,0,	0,0,	202,0,	202,0,	
0,0,	0,0,	199,0,	199,0,	
0,0,	0,0,	200,0,	0,0,	
200,0,	0,0,	0,0,	201,0,	
0,0,	201,0,	200,0,	200,0,	
0,0,	0,0,	0,0,	201,0,	
201,0,	202,0,	0,0,	202,0,	
203,0,	203,0,	0,0,	0,0,	
0,0,	202,0,	202,0,	0,0,	
0,0,	0,0,	0,0,	200,0,	
200,0,	204,0,	204,0,	198,206,	
201,0,	201,0,	205,0,	205,0,	
0,0,	0,0,	0,0,	203,0,	
0,0,	203,0,	202,0,	202,0,	
0,0,	0,0,	0,0,	203,0,	
203,0,	0,0,	0,0,	0,0,	
204,0,	0,0,	204,0,	0,0,	
0,0,	205,0,	0,0,	205,0,	
204,0,	204,0,	0,0,	0,0,	
0,0,	205,0,	205,0,	0,0,	
203,0,	203,0,	0,0,	0,0,	
206,0,	206,0,	200,207,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	204,0,	204,0,	207,0,	
207,0,	0,0,	205,0,	205,0,	
208,0,	208,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	206,0,	
0,0,	206,0,	209,0,	209,0,	
0,0,	0,0,	202,208,	206,0,	
206,0,	0,0,	207,0,	0,0,	
207,0,	0,0,	0,0,	208,0,	
0,0,	208,0,	207,0,	207,0,	
0,0,	0,0,	0,0,	208,0,	
208,0,	209,0,	0,0,	209,0,	
206,0,	206,0,	0,0,	0,0,	
203,209,	209,0,	209,0,	0,0,	
204,210,	210,0,	210,0,	207,0,	
207,0,	211,0,	211,0,	0,0,	
208,0,	208,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	212,0,	
212,0,	0,0,	209,0,	209,0,	
213,0,	213,0,	0,0,	0,0,	
210,0,	0,0,	210,0,	0,0,	
211,0,	0,0,	211,0,	0,0,	
210,0,	210,0,	0,0,	0,0,	
211,0,	211,0,	212,0,	0,0,	
212,0,	0,0,	0,0,	213,0,	
0,0,	213,0,	212,0,	212,0,	
206,211,	0,0,	0,0,	213,0,	
213,0,	210,0,	210,0,	0,0,	
0,0,	211,0,	211,0,	207,212,	
214,0,	214,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	212,0,	
212,0,	0,0,	0,0,	0,0,	
213,0,	213,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	214,0,	
0,0,	214,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	214,0,	
214,0,	0,0,	0,0,	0,0,	
0,0,	211,213,	0,0,	0,0,	
0,0,	0,0,	0,0,	0,0,	
0,0,	0,0,	0,0,	212,214,	
0,0,	0,0,	0,0,	0,0,	
214,0,	214,0,	0,0,	0,0,	
0,0};
struct yysvf yysvec[] = {
0,	0,	0,
yycrank+-1,	0,		0,	
yycrank+-23,	yysvec+1,	0,	
yycrank+-4,	0,		0,	
yycrank+-8,	yysvec+3,	0,	
yycrank+-16,	0,		yyvstop+1,
yycrank+14,	0,		yyvstop+4,
yycrank+0,	0,		yyvstop+7,
yycrank+-19,	0,		yyvstop+9,
yycrank+-21,	0,		yyvstop+11,
yycrank+0,	0,		yyvstop+15,
yycrank+0,	0,		yyvstop+18,
yycrank+0,	0,		yyvstop+21,
yycrank+0,	0,		yyvstop+24,
yycrank+-116,	0,		yyvstop+27,
yycrank+-133,	yysvec+5,	yyvstop+30,
yycrank+-120,	yysvec+5,	yyvstop+33,
yycrank+-170,	0,		yyvstop+36,
yycrank+-183,	yysvec+5,	yyvstop+39,
yycrank+-217,	0,		yyvstop+42,
yycrank+-42,	yysvec+5,	yyvstop+45,
yycrank+-227,	yysvec+5,	yyvstop+48,
yycrank+-262,	yysvec+5,	yyvstop+51,
yycrank+-267,	yysvec+5,	yyvstop+54,
yycrank+-272,	yysvec+5,	yyvstop+57,
yycrank+-305,	yysvec+5,	yyvstop+60,
yycrank+-308,	yysvec+5,	yyvstop+63,
yycrank+0,	yysvec+6,	yyvstop+65,
yycrank+0,	yysvec+8,	0,	
yycrank+0,	0,		yyvstop+67,
yycrank+-57,	yysvec+8,	0,	
yycrank+0,	yysvec+9,	yyvstop+69,
yycrank+-2,	yysvec+9,	yyvstop+72,
yycrank+0,	0,		yyvstop+74,
yycrank+-343,	yysvec+5,	yyvstop+76,
yycrank+-346,	yysvec+5,	yyvstop+78,
yycrank+-379,	yysvec+5,	yyvstop+80,
yycrank+-383,	yysvec+5,	yyvstop+82,
yycrank+-420,	0,		yyvstop+84,
yycrank+-425,	yysvec+5,	yyvstop+86,
yycrank+-439,	yysvec+5,	yyvstop+88,
yycrank+-482,	0,		yyvstop+90,
yycrank+-465,	yysvec+5,	yyvstop+92,
yycrank+-479,	yysvec+5,	yyvstop+94,
yycrank+-515,	yysvec+5,	yyvstop+96,
yycrank+-527,	yysvec+5,	yyvstop+98,
yycrank+-561,	yysvec+5,	yyvstop+100,
yycrank+-595,	0,		yyvstop+102,
yycrank+-598,	0,		yyvstop+104,
yycrank+-609,	yysvec+5,	yyvstop+106,
yycrank+-642,	yysvec+5,	yyvstop+108,
yycrank+-654,	yysvec+5,	yyvstop+110,
yycrank+-659,	yysvec+5,	yyvstop+113,
yycrank+-699,	yysvec+5,	yyvstop+115,
yycrank+-702,	yysvec+5,	yyvstop+117,
yycrank+-717,	0,		yyvstop+119,
yycrank+-713,	yysvec+5,	yyvstop+121,
yycrank+-761,	yysvec+5,	yyvstop+123,
yycrank+-773,	yysvec+5,	yyvstop+125,
yycrank+-776,	yysvec+5,	yyvstop+128,
yycrank+-810,	yysvec+5,	yyvstop+130,
yycrank+-821,	yysvec+5,	yyvstop+132,
yycrank+-847,	yysvec+5,	yyvstop+134,
yycrank+-857,	yysvec+5,	yyvstop+136,
yycrank+-890,	yysvec+5,	yyvstop+138,
yycrank+-893,	yysvec+5,	yyvstop+140,
yycrank+-904,	yysvec+5,	yyvstop+142,
yycrank+-937,	yysvec+5,	yyvstop+144,
yycrank+-952,	yysvec+5,	yyvstop+146,
yycrank+-940,	yysvec+5,	yyvstop+148,
yycrank+-978,	yysvec+5,	yyvstop+150,
yycrank+-996,	yysvec+5,	yyvstop+152,
yycrank+-1014,	0,		yyvstop+154,
yycrank+-1032,	yysvec+5,	yyvstop+157,
yycrank+-1050,	yysvec+5,	yyvstop+159,
yycrank+-1068,	0,		yyvstop+161,
yycrank+-1104,	yysvec+5,	yyvstop+163,
yycrank+-1107,	yysvec+5,	yyvstop+165,
yycrank+-1118,	yysvec+5,	yyvstop+167,
yycrank+-1122,	yysvec+5,	yyvstop+169,
yycrank+-1165,	yysvec+5,	yyvstop+171,
yycrank+-1168,	yysvec+5,	yyvstop+173,
yycrank+-1179,	yysvec+75,	yyvstop+175,
yycrank+-1182,	yysvec+5,	yyvstop+177,
yycrank+-1223,	yysvec+5,	yyvstop+179,
yycrank+-1226,	yysvec+5,	yyvstop+181,
yycrank+-1236,	yysvec+5,	yyvstop+184,
yycrank+-1240,	yysvec+5,	yyvstop+186,
yycrank+-1280,	yysvec+5,	yyvstop+188,
yycrank+-1285,	yysvec+5,	yyvstop+191,
yycrank+-1290,	yysvec+5,	yyvstop+193,
yycrank+-1335,	0,		yyvstop+195,
yycrank+-1323,	yysvec+5,	yyvstop+198,
yycrank+-1361,	yysvec+5,	yyvstop+201,
yycrank+-1349,	yysvec+5,	yyvstop+203,
yycrank+-1394,	yysvec+5,	yyvstop+205,
yycrank+-1397,	yysvec+5,	yyvstop+207,
yycrank+-1408,	yysvec+5,	yyvstop+209,
yycrank+-1434,	yysvec+5,	yyvstop+211,
yycrank+-1451,	yysvec+5,	yyvstop+213,
yycrank+-1468,	yysvec+5,	yyvstop+215,
yycrank+-1484,	yysvec+48,	yyvstop+217,
yycrank+-1494,	yysvec+5,	yyvstop+219,
yycrank+-1527,	yysvec+5,	yyvstop+221,
yycrank+-1540,	yysvec+5,	yyvstop+224,
yycrank+-1543,	yysvec+5,	yyvstop+226,
yycrank+-1576,	yysvec+5,	yyvstop+229,
yycrank+-1581,	yysvec+5,	yyvstop+231,
yycrank+-1586,	yysvec+5,	yyvstop+233,
yycrank+-1620,	yysvec+5,	yyvstop+235,
yycrank+-1623,	yysvec+5,	yyvstop+237,
yycrank+-1635,	yysvec+5,	yyvstop+239,
yycrank+-1661,	yysvec+5,	yyvstop+242,
yycrank+-1679,	yysvec+5,	yyvstop+244,
yycrank+-1696,	yysvec+5,	yyvstop+246,
yycrank+-1715,	yysvec+5,	yyvstop+248,
yycrank+-1733,	yysvec+5,	yyvstop+250,
yycrank+-1751,	yysvec+5,	yyvstop+252,
yycrank+-1777,	yysvec+5,	yyvstop+254,
yycrank+-1787,	yysvec+5,	yyvstop+256,
yycrank+-1813,	yysvec+75,	yyvstop+258,
yycrank+-1824,	yysvec+5,	yyvstop+260,
yycrank+-1850,	yysvec+5,	yyvstop+262,
yycrank+-1862,	yysvec+5,	yyvstop+264,
yycrank+-1867,	yysvec+5,	yyvstop+266,
yycrank+-1908,	yysvec+5,	yyvstop+268,
yycrank+-1911,	yysvec+5,	yyvstop+270,
yycrank+-1921,	yysvec+5,	yyvstop+272,
yycrank+-1954,	yysvec+5,	yyvstop+274,
yycrank+-1967,	yysvec+5,	yyvstop+276,
yycrank+-1970,	yysvec+5,	yyvstop+278,
yycrank+-1980,	yysvec+5,	yyvstop+280,
yycrank+-2013,	yysvec+5,	yyvstop+282,
yycrank+-2024,	yysvec+5,	yyvstop+284,
yycrank+-2027,	yysvec+5,	yyvstop+286,
yycrank+-2063,	yysvec+5,	yyvstop+288,
yycrank+-2073,	yysvec+5,	yyvstop+290,
yycrank+-2089,	yysvec+5,	yyvstop+293,
yycrank+-2099,	yysvec+5,	yyvstop+295,
yycrank+-2133,	yysvec+5,	yyvstop+297,
yycrank+-2136,	yysvec+5,	yyvstop+299,
yycrank+-2146,	yysvec+5,	yyvstop+301,
yycrank+-2149,	yysvec+5,	yyvstop+303,
yycrank+-2182,	yysvec+5,	yyvstop+306,
yycrank+-2192,	yysvec+5,	yyvstop+308,
yycrank+-2208,	yysvec+5,	yyvstop+311,
yycrank+-2218,	yysvec+5,	yyvstop+313,
yycrank+-2251,	yysvec+5,	yyvstop+315,
yycrank+-2254,	yysvec+5,	yyvstop+318,
yycrank+-2265,	yysvec+5,	yyvstop+320,
yycrank+-2268,	yysvec+5,	yyvstop+322,
yycrank+-2308,	yysvec+5,	yyvstop+324,
yycrank+-2312,	yysvec+5,	yyvstop+326,
yycrank+-2323,	yysvec+5,	yyvstop+328,
yycrank+-2326,	yysvec+5,	yyvstop+331,
yycrank+-2366,	yysvec+5,	yyvstop+334,
yycrank+-2369,	yysvec+5,	yyvstop+337,
yycrank+-2382,	yysvec+5,	yyvstop+339,
yycrank+-2385,	yysvec+5,	yyvstop+341,
yycrank+-2424,	yysvec+5,	yyvstop+343,
yycrank+-2427,	yysvec+5,	yyvstop+345,
yycrank+-2439,	yysvec+5,	yyvstop+347,
yycrank+-2483,	yysvec+5,	yyvstop+349,
yycrank+-2486,	yysvec+5,	yyvstop+352,
yycrank+-2497,	yysvec+5,	yyvstop+355,
yycrank+-2501,	yysvec+5,	yyvstop+358,
yycrank+-2540,	yysvec+5,	yyvstop+360,
yycrank+-2543,	yysvec+5,	yyvstop+363,
yycrank+-2555,	yysvec+5,	yyvstop+365,
yycrank+-2558,	yysvec+5,	yyvstop+367,
yycrank+-2598,	yysvec+5,	yyvstop+370,
yycrank+-2601,	yysvec+5,	yyvstop+372,
yycrank+-2613,	yysvec+5,	yyvstop+374,
yycrank+-2616,	yysvec+5,	yyvstop+376,
yycrank+-2655,	yysvec+5,	yyvstop+378,
yycrank+-2659,	yysvec+5,	yyvstop+381,
yycrank+-2670,	yysvec+5,	yyvstop+383,
yycrank+-2673,	yysvec+5,	yyvstop+386,
yycrank+-2713,	yysvec+5,	yyvstop+388,
yycrank+-2717,	yysvec+5,	yyvstop+390,
yycrank+-2727,	yysvec+5,	yyvstop+393,
yycrank+-2731,	yysvec+5,	yyvstop+395,
yycrank+-2767,	yysvec+5,	yyvstop+397,
yycrank+-2772,	yysvec+5,	yyvstop+399,
yycrank+-2777,	yysvec+5,	yyvstop+401,
yycrank+-2810,	yysvec+5,	yyvstop+403,
yycrank+-2813,	yysvec+5,	yyvstop+405,
yycrank+-2826,	yysvec+5,	yyvstop+408,
yycrank+-2852,	yysvec+5,	yyvstop+411,
yycrank+-2868,	yysvec+5,	yyvstop+413,
yycrank+-2871,	yysvec+5,	yyvstop+415,
yycrank+-2885,	yysvec+5,	yyvstop+418,
yycrank+-2918,	yysvec+5,	yyvstop+421,
yycrank+-2928,	yysvec+5,	yyvstop+423,
yycrank+-2931,	yysvec+5,	yyvstop+425,
yycrank+-2944,	yysvec+5,	yyvstop+427,
yycrank+-2977,	yysvec+5,	yyvstop+430,
yycrank+-2987,	yysvec+5,	yyvstop+433,
yycrank+-3003,	yysvec+5,	yyvstop+436,
yycrank+-3013,	yysvec+5,	yyvstop+438,
yycrank+-3046,	yysvec+5,	yyvstop+441,
yycrank+-3051,	yysvec+5,	yyvstop+443,
yycrank+-3061,	yysvec+5,	yyvstop+446,
yycrank+-3087,	yysvec+5,	yyvstop+448,
yycrank+-3100,	yysvec+5,	yyvstop+450,
yycrank+-3105,	yysvec+5,	yyvstop+452,
yycrank+-3143,	yysvec+5,	yyvstop+455,
yycrank+-3154,	yysvec+5,	yyvstop+457,
yycrank+-3159,	yysvec+5,	yyvstop+459,
yycrank+-3169,	yysvec+5,	yyvstop+462,
yycrank+-3204,	yysvec+5,	yyvstop+465,
yycrank+-3208,	yysvec+5,	yyvstop+468,
yycrank+-3218,	yysvec+5,	yyvstop+470,
yycrank+-3223,	yysvec+5,	yyvstop+472,
yycrank+-3263,	yysvec+5,	yyvstop+475,
0,	0,	0};
struct yywork *yytop = yycrank+3325;
struct yysvf *yybgin = yysvec+1;
char yymatch[] = {
  0,   1,   1,   1,   1,   1,   1,   1, 
  1,   9,  10,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  9,   1,  34,   1,   1,   1,   1,   1, 
 40,  40,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,  40,  40,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,  92,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
  1,   1,   1,   1,   1,   1,   1,   1, 
0};
char yyextra[] = {
0,1,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0};
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

/*	Copyright (c) 1989 AT&T	*/
/*	  All Rights Reserved  	*/

#pragma ident	"%Z%%M%	%I%	%E% SMI"

int yylineno =1;
# define YYU(x) x
# define NLSTATE yyprevious=YYNEWLINE
struct yysvf *yylstate [YYLMAX], **yylsp, **yyolsp;
char yysbuf[YYLMAX];
char *yysptr = yysbuf;
int *yyfnd;
extern struct yysvf *yyestate;
int yyprevious = YYNEWLINE;
#if defined(__cplusplus) || defined(__STDC__)
int yylook(void)
#else
yylook()
#endif
{
	register struct yysvf *yystate, **lsp;
	register struct yywork *yyt;
	struct yysvf *yyz;
	int yych, yyfirst;
	struct yywork *yyr;
# ifdef LEXDEBUG
	int debug;
# endif
	char *yylastch;
	/* start off machines */
# ifdef LEXDEBUG
	debug = 0;
# endif
	yyfirst=1;
	if (!yymorfg)
		yylastch = yytext;
	else {
		yymorfg=0;
		yylastch = yytext+yyleng;
		}
	for(;;){
		lsp = yylstate;
		yyestate = yystate = yybgin;
		if (yyprevious==YYNEWLINE) yystate++;
		for (;;){
# ifdef LEXDEBUG
			if(debug)fprintf(yyout,"state %d\n",yystate-yysvec-1);
# endif
			yyt = yystate->yystoff;
			if(yyt == yycrank && !yyfirst){  /* may not be any transitions */
				yyz = yystate->yyother;
				if(yyz == 0)break;
				if(yyz->yystoff == yycrank)break;
				}
#ifndef __cplusplus
			*yylastch++ = yych = input();
#else
			*yylastch++ = yych = lex_input();
#endif
#ifdef YYISARRAY
			if(yylastch > &yytext[YYLMAX]) {
				fprintf(yyout,"Input string too long, limit %d\n",YYLMAX);
				exit(1);
			}
#else
			if (yylastch >= &yytext[ yytextsz ]) {
				int	x = yylastch - yytext;

				yytextsz += YYTEXTSZINC;
				if (yytext == yy_tbuf) {
				    yytext = (char *) malloc(yytextsz);
				    memcpy(yytext, yy_tbuf, sizeof (yy_tbuf));
				}
				else
				    yytext = (char *) realloc(yytext, yytextsz);
				if (!yytext) {
				    fprintf(yyout,
					"Cannot realloc yytext\n");
				    exit(1);
				}
				yylastch = yytext + x;
			}
#endif
			yyfirst=0;
		tryagain:
# ifdef LEXDEBUG
			if(debug){
				fprintf(yyout,"char ");
				allprint(yych);
				putchar('\n');
				}
# endif
			yyr = yyt;
			if ( (uintptr_t)yyt > (uintptr_t)yycrank){
				yyt = yyr + yych;
				if (yyt <= yytop && yyt->verify+yysvec == yystate){
					if(yyt->advance+yysvec == YYLERR)	/* error transitions */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyt->advance+yysvec;
					if(lsp > &yylstate[YYLMAX]) {
						fprintf(yyout,"Input string too long, limit %d\n",YYLMAX);
						exit(1);
					}
					goto contin;
					}
				}
# ifdef YYOPTIM
			else if((uintptr_t)yyt < (uintptr_t)yycrank) {	/* r < yycrank */
				yyt = yyr = yycrank+(yycrank-yyt);
# ifdef LEXDEBUG
				if(debug)fprintf(yyout,"compressed state\n");
# endif
				yyt = yyt + yych;
				if(yyt <= yytop && yyt->verify+yysvec == yystate){
					if(yyt->advance+yysvec == YYLERR)	/* error transitions */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyt->advance+yysvec;
					if(lsp > &yylstate[YYLMAX]) {
						fprintf(yyout,"Input string too long, limit %d\n",YYLMAX);
						exit(1);
					}
					goto contin;
					}
				yyt = yyr + YYU(yymatch[yych]);
# ifdef LEXDEBUG
				if(debug){
					fprintf(yyout,"try fall back character ");
					allprint(YYU(yymatch[yych]));
					putchar('\n');
					}
# endif
				if(yyt <= yytop && yyt->verify+yysvec == yystate){
					if(yyt->advance+yysvec == YYLERR)	/* error transition */
						{unput(*--yylastch);break;}
					*lsp++ = yystate = yyt->advance+yysvec;
					if(lsp > &yylstate[YYLMAX]) {
						fprintf(yyout,"Input string too long, limit %d\n",YYLMAX);
						exit(1);
					}
					goto contin;
					}
				}
			if ((yystate = yystate->yyother) && (yyt= yystate->yystoff) != yycrank){
# ifdef LEXDEBUG
				if(debug)fprintf(yyout,"fall back to state %d\n",yystate-yysvec-1);
# endif
				goto tryagain;
				}
# endif
			else
				{unput(*--yylastch);break;}
		contin:
# ifdef LEXDEBUG
			if(debug){
				fprintf(yyout,"state %d char ",yystate-yysvec-1);
				allprint(yych);
				putchar('\n');
				}
# endif
			;
			}
# ifdef LEXDEBUG
		if(debug){
			fprintf(yyout,"stopped at %d with ",*(lsp-1)-yysvec-1);
			allprint(yych);
			putchar('\n');
			}
# endif
		while (lsp-- > yylstate){
			*yylastch-- = 0;
			if (*lsp != 0 && (yyfnd= (*lsp)->yystops) && *yyfnd > 0){
				yyolsp = lsp;
				if(yyextra[*yyfnd]){		/* must backup */
					while(yyback((*lsp)->yystops,-*yyfnd) != 1 && lsp > yylstate){
						lsp--;
						unput(*yylastch--);
						}
					}
				yyprevious = YYU(*yylastch);
				yylsp = lsp;
				yyleng = yylastch-yytext+1;
				yytext[yyleng] = 0;
# ifdef LEXDEBUG
				if(debug){
					fprintf(yyout,"\nmatch ");
					sprint(yytext);
					fprintf(yyout," action %d\n",*yyfnd);
					}
# endif
				return(*yyfnd++);
				}
			unput(*yylastch);
			}
		if (yytext[0] == 0  /* && feof(yyin) */)
			{
			yysptr=yysbuf;
			return(0);
			}
#ifndef __cplusplus
		yyprevious = yytext[0] = input();
		if (yyprevious>0)
			output(yyprevious);
#else
		yyprevious = yytext[0] = lex_input();
		if (yyprevious>0)
			lex_output(yyprevious);
#endif
		yylastch=yytext;
# ifdef LEXDEBUG
		if(debug)putchar('\n');
# endif
		}
	}
#if defined(__cplusplus) || defined(__STDC__)
int yyback(int *p, int m)
#else
yyback(p, m)
	int *p;
#endif
{
	if (p==0) return(0);
	while (*p) {
		if (*p++ == m)
			return(1);
	}
	return(0);
}
	/* the following are only used in the lex library */
#if defined(__cplusplus) || defined(__STDC__)
int yyinput(void)
#else
yyinput()
#endif
{
#ifndef __cplusplus
	return(input());
#else
	return(lex_input());
#endif
	}
#if defined(__cplusplus) || defined(__STDC__)
void yyoutput(int c)
#else
yyoutput(c)
  int c; 
#endif
{
#ifndef __cplusplus
	output(c);
#else
	lex_output(c);
#endif
	}
#if defined(__cplusplus) || defined(__STDC__)
void yyunput(int c)
#else
yyunput(c)
   int c; 
#endif
{
	unput(c);
	}
