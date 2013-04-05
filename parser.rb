
MarblToken = Struct.new :type, :value

class MarblParser
	def initialize
		@tree = []
	end
	def parse str, tree=nil
		str = str.dup
		tree ||= @tree

		#str.sub! /^[[:space:]]+/, ''
		str.sub! /^[^[[:graph:]]]+/, ''
		case str
		when /^#/
			str = parse_line_comment str, tree
		when /^"/
			str = parse_dq_string str, tree
		when /^'/
			str = parse_sq_string str, tree
		#when /^`/
		#	str = parse_ex_string str, tree
		when /^:/
			str = parse_symbol str, tree
		when /^\$/
			str = parse_gvar str, tree
		when /^@@/
			str = parse_cvar str, tree
		when /^@/
			str = parse_ivar str, tree
		when /^[[:digit:]]/
			str = parse_number str, tree
		when /^[[:word:]]/
			str = parse_word str, tree
		end
	end

	def parse_line_comment str, tree
		m = /^#(.*)$/.match str
		tree << MarblToken.new :line_comment, m[1]
		str[ m[0].length..-1 ]
	end

	def parse_dq_string str, tree
		# todo: interpolation
		m = /^"(\\.|[^\\"]+)"/.match str
		tree << MarblToken.new :dq_string, m[1]
		str[ m[0].length..-1 ]
	end

	def parse_sq_string str, tree
		m = /^'(\\.|[^\\']+)'/.match str
		tree << MarblToken.new :sq_string, m[1]
		str[ m[0]..length..-1 ]
	end

	def parse_symbol str, tree
		subtree = []
		case str[1]
		when '"'
			str = parse_dq_string str[1..-1], subtree
		when "'"
			str = parse_sq_string str[1..-1], subtree
		else
			str = parse_word str[1..-1], subtree
		end
		tree << MarblToken.new :symbol, subtree # fixme: nested interpolation?
		str
	end

	def parse_gvar str, tree
		tmp = []
		str = parse_word str[1..-1], tmp
		tree << MarblToken.new :gvar, "$#{tmp[0][:value]}"
		str
	end

	def parse_cvar str, tree
		tmp = []
		str = parse_word str[2..-1], tmp
		tree << MarblToken.new :cvar, "@@#{tmp[0][:value]}"
		str
	end

	def parse_ivar str, tree
		tmp = []
		str = parse_word str[1..-1], tmp
		tree << MarblToken.new :ivar, "@#{tmp[0][:value]}"
		str
	end

	def parse_number str, tree
		if str[0] == '0'
			case str[1]
			when 'x', 'X'
				parse_hex str[2..-1], tree
			when 'b', 'B'
				parse_binary str[2..-1], tree
			when 'o', 'O'
				parse_octal str[2..-1], tree
			else
				parse_octal str[1..-1], tree
			end
		else
			parse_decimal str, tree
		end
	end

	def parse_decimal str, tree
		# while str[0] in '0'..'9' or '_', or str[0] == '_', or str[0] == '.' {and go into float mode}, or str[0] == 'e' and in float mode ...
	end

end


