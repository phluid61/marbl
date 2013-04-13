
# class definition
class <const>
<...>
end

class <const> < <???>
<...>
end

# module definition
module <const>
<...>
end

# function definition
def <id> <argslist>
<...>
end

#####

class_def = open_class class_body kEND
module_def = open_module class_body kEND
open_class = open_class_simple | open_class_inherit
open_class_simple = kCLASS const
open_class_inherit = kCLASS const '<' expr
open_module = kMODULE const

func_def = open_func func_body kEND
open_func = open_func_argless | open_func_args
open_func_argless = kDEF id
open_func_args = kDEF id '(' args ')'

args = positional_args opt_args varargs, block_args
positional_args = EMPTY | arg ( ',' arg )*
arg = id
opt_args = EMPTY | opt_arg ( ',' opt_arg )*
opt_arg = arg '=' arg_default
arg_default = kNIL | kNULL | literal
varargs = EMPTY | vararg
vararg = '*' arg
block_args = EMPTY | block_arg
block_arg = '&' arg

class_body = #const_defs class_defs module_defs

func_body = #...

