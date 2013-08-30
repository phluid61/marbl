## 2013-08-30

* decided to log this journey
* why?
  * all good polyglots want to make their own language
    (programmers and real-world linguists alike)
  * why not?
    * (and: how hard can it be?)
* why yacc/bison?
  * MOO included .y file
  * Ruby uses .y file
* where to begin?
  * teh googles
  * .. which leads to http://ashimg.tripod.com/Parser.html

Things to remember:

* Terminals: `%token <stack-member> tokenName`
  * UPPERCASE
* Non-terminals: `%type <stack-member> tokenName`
  * lowercase
  * default type is integer
* `$$` = LHS, `$1` = first RHS, `$2` = second RHS, etc.

### Writing the Lex

1. identify tokens
2. write regexen for tokens
3. identify lex substitutions (if possible)
4. identify possible start states (to avoid reduce/reduce conflicts) and break conflicting tokens into multiples
  * i.e. if two tokens have the same regex, identify the states in which they exist
  * e.g. if a bareword token can be a _classname_ or a _variable_, use the keywords `class` or `var` to define the state

    %{
      #include <string.h>
    %}
    %s CLASS_STATE VAR_STATE
    %%
    class { BEGIN CLASS_STATE; return CLASS; }
    var { BEGIN VAR_STATE; return VAR; }
    <CLASS_STATE>[a-z][a-zA-Z0-9_]* { BEGIN INITIAL; strcpy(yylval.stval,yytext); return CLASS_NAME; }
    <VAR_STATE>[a-z][a-zA-Z0-9_]* { BEGIN INITIAL; strcpy(yylval.stval,yytext); return VAR_NAME; }
    %%
    int yywrap(void){ return 1; }

### Writing the Yacc

1. identify terminals and non-terminals from BNF and Lex
2. code grammar rules (with no action), copile, link to lex, test for reduce/reduce conflicts
  * fix them in lex
3. look for shift/reduce conflicts
  * use precedence
  * use associativity (`%left, %right %noassoc %prec`)
  * ???
  * profit!
4. write rules for syntax errors
5. code yyerror function in subroutine section (the end)
6. design Data Structure ...
7. formulate stack ...
8. bind tokens and yacc variables (non-terminals) to types

