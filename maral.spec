
Keywords
--------

class
	open a class definition

module
	open a module definition

def
	define function

alias
	(copy a symbolic reference)

if
	begin an "if" statement
	modify previous statement

elsif
	continue an "if" statement with a secondary test

unless
	begin an "unless" statement
	modify previous statement

else
	continue an "if" or "unless" statement with a final alternative branch

while
	begin a "while" loop
	modify previous statement

until
	begin an "until" loop
	modify previous statement

case
	begin a "case" statement

when
	define a condition in a "case" statement

do
	begin an arbitrary code block

end
	terminate the current statement/loop/block

return
	return from the current function

break
	return from the current loop/block

next
	in a loop: abort the current iteration, repeat
	in a case: abort the current condition, go to next (skip test?)

raise
	signal an error and abort

rescue
	intercept a raised error

throw
	throw a token up the stack and abort

catch
	catch a thrown token

ensure
	begin a block of code that is executed after regular execution and/or any throws or raises

Statements
----------

stmts:
	EMPTY
|	<stmts> <stmt> ';'
;

stmt:
	<assignment_stmt>
|	<void_stmt>
;

assignment_stmt:
	<lhs> '=' <rhs>
;
# fixme
lhs:
	<id>
;
rhs:
	<stmt>
;

void_stmt:
	<complex_stmt> <modifier_part>
end

modifier_part:
	EMPTY
|	<if_modifier>
|	<unless_modifier>
|	<while_modifier>
|	<until_modifier>
;
if_modifier:
	if '(' <stmt> ')'
;
unless_modifier:
	unless '(' <stmt> ')'
;
while_modifier:
	while '(' <stmt> ')'
;
until_modifier:
	until '(' <stmt> ')'
;

complex_stmt:
	<class_def>
|	<module_def>
|	<func_def>
|	<if_stmt>
|	<unless_stmt>
|	<while_stmt>
|	<until_stmt>
|	<case_stmt>
|	<do_no_args>
|	<return_stmt>
|	<break_stmt>
|	<next_stmt>
|	<raise_stmt>
|	<throw_stmt>
|	<catch_stmt>
|	<simple_stmt>
;

class_def:
	class '<<' <id> ':' <stmts> end
|	class <id> '<' <id> ':' <stmts> end
|	class <id> ':' <stmts> end
;

module_def:
	module <id> '<' <id> ':' <stmts> end
|	module <id> ':' <stmts> end
;

func_def:
	def <id> '(' <def_args> ')' ':' <stmts> <rescues> <ensure_part> end
|	def <id> ':' <stmts> <rescues> <ensure_part> end
;

def_args:
	EMPTY
|	<def_pos_args> ',' <def_kw_args> ',' <def_block_arg>
|	<def_pos_args> ',' <def_kw_args>
|	<def_pos_args> ',' <def_block_arg>
|	<def_pos_args>
|	<def_kw_args> ',' <def_block_arg>
|	<def_kw_args>
|	<def_block_arg>
;
def_pos_args:
	<pos_args> ',' <opt_args> ',' <splat_arg>
|	<pos_args> ',' <opt_args>
|	<pos_args> ',' <splat_arg>
|	<pos_args>
|	<opt_args> ',' <splat_arg>
|	<opt_args>
|	<splat_arg>
;
def_kw_args:
	<kw_args> ',' <kw_opt_args> ',' <kw_rest_arg>
|	<kw_args> ',' <kw_opt_args>
|	<kw_args> ',' <kw_rest_arg>
|	<kw_args>
|	<kw_opt_args> ',' <kw_rest_arg>
|	<kw_opt_args>
|	<kw_rest_arg>
;
pos_args:
	<pos_arg>
|	<pos_args> ',' <pos_arg>
;
pos_arg:
	<id>
;
opt_args:
	<opt_arg>
|	<opt_args> ',' <opt_arg>
;
opt_arg:
	<id> '=' <simple_stmt>
;
splat_arg:
  /* capture in array */
	'*' <id>
| /* ignore rest */
	'*'
;
kw_args:
	<kw_arg>
|	<kw_args> ',' <kw_arg>
;
kw_arg:
	<id> ':'
;
opt_kw_args:
	<opt_kwarg>
|	<opt_kwargs> ',' <opt_kwarg>
;
opt_kw_arg:
	<id> ':' <simple_stmt>
;
kw_rest_arg:
  /* capture in hash */
	'**' <id>
| /* ignore rest */
	'**'
;
block_arg:
	'&' <id>
;

if_stmt:
	if <id> '(' <stmt> ')' ':' <stmts> <elsifs> <else_part> end
|	if '(' <stmt> ')' ':' <stmts> <elsifs> <else_part> end
;

elsifs:
    EMPTY
|	<elsifs> <elsif_stmt>
;
elsif_stmt:
	elsif '(' <stmt> ')' ':' <stmts>
;

unless_stmt:
	unless <id> '(' <stmt> ')' ':' <stmts> <else_part> end
|	unless '(' <stmt> ')' ':' <stmts> <else_part> end
;

else_part:
	EMPTY
|	else_stmt
;
else_stmt:
	else ':' <stmts>
;

while_stmt:
	while <id> '(' <stmt> ')' ':' <stmts> end
|	while '(' <stmt> ')' ':' <stmts> end
;

until_stmt:
	until <id> '(' <stmt> ')' ':' <stmts> end
|	until '(' <stmt> ')' ':' <stmts> end
;

case_stmt:
	case <id> '(' <stmt> ')' ':' <whens> <else_part> end
|	case '(' <stmt> ')' ':' <whens> <else_part> end
| /* ???: *'
	case <id> ':' <whens> <else_part> end
| /* ???: *'
	case ':' <whens> <else_part> end
;

whens:
	EMPTY
|	<whens> <when_stmt>
;
when_stmt:
	when '(' <stmt> ')' <stmts>
;

do_stmt:
	<do_with_args>
|	<do_no_args>
;
do_with_args:
	do <id> '|' <do_args> '|' ':' <stmts> <rescues> <ensure_part> end
|	do '|' <do_args> '|' ':' <stmts> <rescues> <ensure_part> end
;
do_no_args:
	do <id> ':' <stmts> <rescues> <ensure_part> end
|	do ':' <stmts> <rescues> <ensure_part> end
;

# todo: splat?
do_args:
	EMPTY
|	<do_args_n>
;
do_args_n:
	<id>
|	<do_args_n> ',' <id>
;

return_stmt:
	return '(' <stmt> ')'
|	return
;

break_stmt:
	break <id> '(' <stmt> ')'
|	break '(' <stmt> ')'
|	break <id>
|	break
;

next_stmt:
	next <id>
|	next
;

raise_stmt:
	raise '(' <stmt> ')'
;

rescues:
	EMPTY
|	<rescues> <rescue_stmt>
;
rescue_stmt:
	rescue '(' <rescue_args> ')' ':' <stmts>
|	rescue ':' <stmts>
;

rescue_args:
	EMPTY
|	<rescue_args_n>
;
rescue_args_n:
	<rescue_arg>
|	<rescue_args> ',' <rescue_arg>
;
# fixme
rescue_arg:
	<id> '=>' <id>
|	<id>
;

throw_stmt:
	throw '(' <stmt> ')'
;

catch_stmt:
	catch '(' <catch_args> ')' do <stmts> end
;

catch_args:
	EMPTY
|	<catch_args_n>
;
catch_args_n:
	<catch_arg>
|	<catch_args> ',' <catch_arg>
;
# fixme
catch_arg:
	<id>
;

ensure_part:
	EMPTY
|	<ensure_stmt>
;

ensure_stmt:
	ensure ':' <stmts>
;

# fixme ------------------------------------------------------------------
# todo: unary (left) operators, ternary operators, [], []=, ...

simple_stmt:
	<var> <funcalls>
;

var:
	<id>
;

funcalls:
	EMPTY
|	<funcalls> <funcall>
;
funcall:
	'.' <id> <args_part> <do_part>
|	<bin_op_assign>
|	<bin_op>
;

args_part:
	EMPTY
|	'(' args_list ')'
;
args_list:
	EMPTY
|	c_pos_args ',' c_kw_args ',' c_block_arg
|	c_pos_args ',' c_kw_arg
|	c_pos_args ',' c_block_arg
|	c_kw_args ',' c_block_arg
|	c_block_arg
;
c_pos_args:
	<c_pos_arg>
|	<c_pos_args> ',' <c_pos_arg>
;
c_pos_arg:
	<stmt>
;
c_kw_args:
	<c_kw_arg>
|	<c_kw_args> ',' <c_kw_arg>
;
c_kw_arg:
	<id> ':' <stmt>
;
c_block_arg:
	'&' <stmt>
;

bin_op_assign:
	<op_assign> <stmt>
;

bin_op:
	<op> <stmt>
;
