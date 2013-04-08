
class MarblParser

	def parse_negative_number str, tree
		tmp = []
		str = parse_number str[1..-1], tmp
		token = tmp[0]
		token[:value] = -token[:value]
		tree << token
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
			when 'o', 'O'
				parse_octal str[2..-1], tree
			when /[0-7]/
				parse_octal str[1..-1], tree
			when '', /[^[:word:]]/
				tree << MarblToken.new( :integer, 0 )
				str[1..-1]
			else
				raise MarblParseError, "invalid number format #{c}"
			end
		when /[1-9]/
			parse_decimal str, tree
		else
			raise MarblParseError, "unexpected `#{c}' in number"
		end
	end

	def parse_hex str, tree
		_parse_number 16, /[[:xdigit:]]/, str, tree
	end

	def parse_decimal str, tree
		_parse_number 10, /[0-9]/, str, tree
	end

	def parse_octal str, tree
		_parse_number 8, /[0-7]/, str, tree
	end

	def parse_binary str, tree
		_parse_number 2, /[01]/, str, tree
	end

	def _parse_number base, digit, str, tree
		n = ''
		i = 0
		until (c=str[i,1]).empty?
			case c
#			when '_'
			when digit
				n << c
			when '.'
				if str[i+1,1] =~ digit
					return _parse_float( n, base, digit, str[i+1..-1], tree )
				else
					break
				end
			when 'e', 'E'
				return _parse_float_decexp( n.to_i(base), 1, str[i+1..-1], tree)
			when 'p', 'P'
				return _parse_float_binexp( n.to_i(base), 1, str[i+1..-1], tree)
			when /[^[:word:]]/
				break
			else
				raise MarblParseError, "unexpected `#{c}' in number"
			end
			#str = str[1..-1]
			i += 1
		end
		tree << MarblToken.new( :integer, n.to_i(base) )
		str[i..-1]
	end
	def _parse_float n, base, digit, str, tree
		m = ''
		i = 0
		until (c=str[i,1]).empty?
			case c
#			when '_'
			when digit
				m << c
			when 'e', 'E'
				return _parse_float_decexp( (n+m).to_i(base), base ** m.length, str[i+1..-1], tree )
			when 'p', 'P'
				return _parse_float_binexp( (n+m).to_i(base), base ** m.length, str[i+1..-1], tree )
			when /[^[:word:]]/
				break
			else
				raise MarblParseError, "unexpected `#{c}' in number"
			end
			i += 1
		end
		numer = (n + m).to_i(base)
		denom = base ** m.length
		tree << MarblToken.new( :float, Rational(numer, denom) )
		str[i..-1]
	end
	def _parse_float_decexp n, b, str, tree
		x = ''
		neg = nil
		i = 0
		until (c=str[i,1]).empty?
			case c
			when '-'
				raise MarblParseError, "unexpected `#{c}' in number" unless neg.nil?
				neg = true
			when '+'
				raise MarblParseError, "unexpected `#{c}' in number" unless neg.nil?
				neg = false
			when /[0-9]/
				neg = false if neg.nil?
				x << c
			when /[^[:word:]]/
				break
			else
				raise MarblParseError, "unexpected `#{c}' in number"
			end
			i += 1
		end
		x = neg ? x.to_i : -x.to_i
		denom = b * (10 ** x)
		tree << MarblToken.new( :float, Rational(n, denom) )
		str[i..-1]
	end
	def _parse_float_binexp n, b, str, tree
		x = ''
		neg = nil
		i = 0
		until (c=str[i,1]).empty?
			case c
			when '-'
				raise MarblParseError, "unexpected `#{c}' in number" unless neg.nil?
				neg = true
			when '+'
				raise MarblParseError, "unexpected `#{c}' in number" unless neg.nil?
				neg = false
			when /[0-9]/
				neg = false if neg.nil?
				x << c
			when /[^[:word:]]/
				break
			else
				raise MarblParseError, "unexpected `#{c}' in number"
			end
			i += 1
		end
		x = neg ? x.to_i : -x.to_i
		denom = b * (2 ** x)
		tree << MarblToken.new( :float, Rational(n, denom) )
		str[i..-1]
	end

end

