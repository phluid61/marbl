%{
#define TRUE  (-1)
#define FALSE (0)
#define EMPTY /**/
%}

%token	<integer>	tINTEGER
%token	<object>	tOBJECT
%token	<float>		tFLOAT
%token	<string>	tSTRING tID
%token	<error>		tERROR
%token	tIF tELSE tELSIF tUNLESS tEND tRETURN
%token	tWHILE tUNTIL tDO tBEGIN tRAISE tRESCUE tENSURE tTHROW tCATCH tNEXT tBREAK
%token	tARROW tDARROW

%nonassoc	m_if m_unless m_while m_until
%left		k_or k_and
%right		k_not
%nonassoc	k_defined
%right		'='
%nonassoc	'?' ':'
%left		tOR
%left		tAND
%nonassoc	tCMP tEQ tEQQ tNEQ tLIKE tNLIKE
%left		'>' tEQ '<' tLE
%left		'|' '^'
%left		'&'
%left		tSHL tSHR
%left		'+' '-'
%left		'*' '/' '%'
%right		tNEGATIVE tUMINUS
%right		tPOW
%right		'!' '~' tUPLUS

%%

program:
	statements
		{ prog_start = $1; }
;

statements:
	EMPTY
		{ $$ = 0; }
	| statements statement
		{
			if ($1) {
				Stmt *tmp = $1;
				while (tmp->next)
					tmp = tmp->next;
				tmp->next = $2;
				$$ = $1;
			} else {
				$$ = $2;
			}
		}
;

statement:
	  tBEGIN ':'
		{
			push_block_name(0);
		}
	  statements excepts ensurepart tEND
		{
			$$ = alloc_stmt(STMT_BLOCK);
			$$->s.block.id = -1;
			$$->s.block.body = $4;
			$$->s.block.excepts = $5;
			$$->s.block.ensure = $6;
		}
	| tBEGIN tID ':'
		{
			push_block_name($2);
		}
	  statements excepts ensurepart tEND
		{
			$$ = alloc_stmt(STMT_BLOCK);
			$$->s.block.id = find_id($2);
			$$->s.block.body = $5;
			$$->s.block.excepts = $6;
			$$->s.block.ensure = $7;
		}
	| tIF '(' expr ')' statements elsifs elsepart tEND
		{
			$$ = alloc_stmt(STMT_COND);
			$$->s.cond.branches = alloc_cond_arm($3, TRUE, $5);
			$$->s.cond.branches->next = $6;
			$$->s.cond.otherwise = $7;
		}
	| tUNLESS '(' expr ')' statements elsepart tEND
		{
			$$ = alloc_stmt(STMT_COND);
			$$->s.cond.match = 0;
			$$->s.cond.branches = alloc_cond_arm($3, FALSE, $5);
			$$s.cond.otherwise = $6;
		}
	| tWHILE '(' expr ')'
		{
			push_loop_name(0);
		}
	  statements tEND
		{
			$$ = alloc_stmt(STMT_WHILE);
			$$->s.loop.id = -1;
			$$->s.loop.test = TRUE;
			$$->s.loop.condition = $3;
			$$->s.loop.body = $6;
		}
	| tWHILE tID '(' expr ')'
		{
			push_loop_name($2);
		}
	  statements tEND
		{
			$$ = alloc_stmt(STMT_WHILE);
			$$->s.loop.id = find_id($2);
			$$->s.loop.test = TRUE;
			$$->s.loop.condition = $3;
			$$->s.loop.body = $7;
		}
	| tUNTIL '(' expr ')'
		{
			push_loop_name(0);
		}
	  statements tEND
		{
			$$ = alloc_stmt(STMT_WHILE);
			$$->s.loop.id = -1;
			$$->s.loop.test = FALSE;
			$$->s.loop.condition = $3;
			$$->s.loop.body = $6;
		}
	| tUNTIL tID '(' expr ')'
		{
			push_loop_name($2);
		}
	  statements tEND
		{
			$$ = alloc_stmt(STMT_WHILE);
			$$->s.loop.id = find_id($2);
			$$->s.loop.test = FALSE;
			$$->s.loop.condition = $3;
			$$->s.loop.body = $7;
		}
;

