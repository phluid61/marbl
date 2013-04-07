
MarblToken = Struct.new :type, :value

class MarblParseError < Exception
end

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
		else
			str = parse_symbol str, tree
		end
	end

	def parse_line_comment str, tree
		m = /^#(.*)$/.match str
		tree << MarblToken.new( :line_comment, m[1] )
		str[ m[0].length..-1 ]
	end

	def parse_dq_string str, tree
		# todo: interpolation
		m = /^"(\\.|[^\\"]+)"/.match str
		tree << MarblToken.new( :dq_string, m[1] )
		str[ m[0].length..-1 ]
	end

	def parse_sq_string str, tree
		m = /^'(\\.|[^\\']+)'/.match str
		tree << MarblToken.new( :sq_string, m[1] )
		str[ m[0].length..-1 ]
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
		tree << MarblToken.new( :symbol, subtree)
		str
	end

	def parse_gvar str, tree
		tmp = []
		str = parse_word str[1..-1], tmp
		tree << MarblToken.new( :gvar, "$#{tmp[0][:value]}" )
		str
	end

	def parse_cvar str, tree
		tmp = []
		str = parse_word str[2..-1], tmp
		tree << MarblToken.new( :cvar, "@@#{tmp[0][:value]}" )
		str
	end

	def parse_ivar str, tree
		tmp = []
		str = parse_word str[1..-1], tmp
		tree << MarblToken.new( :ivar, "@#{tmp[0][:value]}" )
		str
	end

	def parse_number str, tree
		case str[0,1]
		when '0'
			case c=str[1,1]
			when 'x', 'X'
				parse_hex str[2..-1], tree
			when 'b', 'B'
				parse_binary str[2..-1], tree
			when 'o', 'O', /[0-7]/
				parse_octal str[2..-1], tree
			else
				throw MarblParseError, "invalid number format #{c}"
			end
		when /[1-9]/
			parse_decimal str, tree
		else
			tree << MarblToken.new( :number_decimal, 0 )
		end
	end

	def parse_decimal str, tree
		# while str[0] in '0'..'9' or '_', or str[0] == '_', or str[0] == '.' {and go into float mode}, or str[0] == 'e' and in float mode ...
		
	end

	def parse_octal str, tree
		# ... (error on 8,9)
	end

end
