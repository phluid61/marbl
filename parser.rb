
require_relative 'token'
require_relative 'errors'

class MarblParser
	def initialize
		@tree = []
	end

	def parse str, tree=nil
		str = str.dup
		tree ||= @tree

		#str.sub! /^[[:space:]]+/, ''
		str.sub! /^[^[:graph:]]+/, ''
		case str[0,1]
		when '#'
			str = parse_line_comment str, tree
		when '"'
			str = parse_dq_string str, tree
		when "'"
			str = parse_sq_string str, tree
		#when '`'
		#	str = parse_ex_string str, tree
		when ':'
			str = parse_symbol str, tree
		when '$'
			str = parse_gvar str, tree
		when '@'
			if str[1,1] == '@'
				str = parse_cvar str, tree
			else
				str = parse_ivar str, tree
			end
		when /[[:digit:]]/
			str = parse_number str, tree
		when /[[:word:]]/
			str = parse_word str, tree
		when '-'
			if str[1,1] =~ /[[:digit:]]/
				str = parse_negative_number str[1..-1], tree
			else
				str = parse_symbol str, tree
			end
		when '+'
			if str[1,1] =~ /[[:digit:]]/
				str = parse_number str[1..-1], tree
			else
				str = parse_symbol str, tree
			end
		else
			str = parse_symbol str, tree
		end
	end

end

require_relative 'parser/comment'
require_relative 'parser/string'
require_relative 'parser/variable'
require_relative 'parser/number'

