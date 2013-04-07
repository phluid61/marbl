
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
		_parse_number 16, /[0-9A-F]/i, str, tree
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
		until str.empty?
			case c=str[0,1]
#			when '_'
			when digit
				n << c
			when '.'
				if str[1,1] =~ digit
					return _parse_float( n, base, digit, str[1..-1], tree )
				else
					break
				end
			when 'e', 'E'
				return _parse_float_decexp( n.to_i(base), 1, str[1..-1], tree)
			when 'p', 'P'
				return _parse_float_binexp( n.to_i(base), 1, str[1..-1], tree)
			when /[^[:word:]]/
				break
			else
				raise MarblParseError, "unexpected `#{c}' in number"
			end
			str = str[1..-1]
		end
		tree << MarblToken.new( :integer, n.to_i(base) )
		str
	end
	def _parse_float n, base, digit, str, tree
		m = ''
		until str.empty?
			case c=str[0,1]
#			when '_'
			when digit
				m << c
			when 'e', 'E'
				return _parse_float_decexp( (n+m).to_i(base), base ** m.length, str[1..-1], tree )
			when 'p', 'P'
				return _parse_float_binexp( (n+m).to_i(base), base ** m.length, str[1..-1], tree )
			when /[^[:word:]]/
				break
			else
				raise MarblParseError, "unexpected `#{c}' in number"
			end
			str = str[1..-1]
		end
		numer = (n + m).to_i(base)
		denom = base ** m.length
		tree << MarblToken.new( :float, Rational(numer, denom) )
		str
	end
	def _parse_float_decexp n, b, str, tree
		x = ''
		neg = nil
		until str.empty?
			case c=str[0,1]
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
			str = str[1..-1]
		end
		x = neg ? x.to_i : -x.to_i
		denom = b * (10 ** x)
		tree << MarblToken.new( :float, Rational(n, denom) )
		str
	end
	def _parse_float_binexp n, b, str, tree
		x = ''
		neg = nil
		until str.empty?
			case c=str[0,1]
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
			str = str[1..-1]
		end
		x = neg ? x.to_i : -x.to_i
		denom = b * (2 ** x)
		tree << MarblToken.new( :float, Rational(n, denom) )
		str
	end

end


$parser = MarblParser.new
def parse_num n
	t = []
	s = $parser.parse_number( n, t )
	[s, t[0].value.to_f]
end

require 'test/unit'
class Test_parser < Test::Unit::TestCase
	def test_dec_ints
		assert_equal( ['',0.0], parse_num( '0' ))
		assert_equal( ['',1.0], parse_num( '1' ))
		assert_equal( [' ',12.0], parse_num( '12 ' ))
		assert_equal( [' 3',12.0], parse_num( '12 3' ))
		assert_equal( ['.foo',12.0], parse_num( '12.foo' ))
	end
	def test_dec_floats
		assert_equal( ['',1.2], parse_num( '1.2' ))
		assert_equal( ['',1200.0], parse_num( '1.2e3' ))
		assert_equal( ['',0.0012], parse_num( '1.2e-3' ))
		assert_equal( ['',10.0], parse_num( '1e1' ))
		assert_equal( ['',0.1], parse_num( '1e-1' ))
		assert_equal( ['',2.0], parse_num( '1p1' ))
		assert_equal( ['',0.5], parse_num( '1p-1' ))

		assert_equal( ['.foo',1.2], parse_num( '1.2.foo' ))
		assert_equal( ['.foo',1200.0], parse_num( '1.2e3.foo' ))
		assert_equal( ['.foo',0.0012], parse_num( '1.2e-3.foo' ))
		assert_equal( ['.foo',10.0], parse_num( '1e1.foo' ))
		assert_equal( ['.foo',0.1], parse_num( '1e-1.foo' ))
		assert_equal( ['.foo',2.0], parse_num( '1p1.foo' ))
		assert_equal( ['.foo',0.5], parse_num( '1p-1.foo' ))
	end
	def test_ints
		assert_equal( ['',16.0], parse_num( '0x10' ))
		assert_equal( ['',2.0], parse_num( '0b10' ))
		assert_equal( ['',8.0], parse_num( '0o10' ))
		assert_equal( ['',8.0], parse_num( '010' ))
	end
	def test_floats
		assert_equal( ['',16.0625], parse_num( '0x10.1' ))
		assert_equal( ['',2.5], parse_num( '0b10.1' ))
		assert_equal( ['',8.125], parse_num( '0o10.1' ))
		assert_equal( ['',8.125], parse_num( '010.1' ))
	end
	def test_floats_imp
		assert_equal( ['',4321.0], parse_num( '0x10e1' )) # quirk!
		assert_equal( ['',20.0], parse_num( '0b10e1' ))
		assert_equal( ['',80.0], parse_num( '0o10e1' ))
		assert_equal( ['',80.0], parse_num( '010e1' ))

		assert_equal( ['',32.0], parse_num( '0x10p1' ))
		assert_equal( ['',4.0], parse_num( '0b10p1' ))
		assert_equal( ['',16.0], parse_num( '0o10p1' ))
		assert_equal( ['',16.0], parse_num( '010p1' ))

		assert_equal( ['',16.117431640625], parse_num( '0x10.1e1' )) # quirk!
		assert_equal( ['',25.0], parse_num( '0b10.1e1' ))
		assert_equal( ['',81.25], parse_num( '0o10.1e1' ))
		assert_equal( ['',81.25], parse_num( '010.1e1' ))

		assert_equal( ['',32.125], parse_num( '0x10.1p1' ))
		assert_equal( ['',5.0], parse_num( '0b10.1p1' ))
		assert_equal( ['',16.25], parse_num( '0o10.1p1' ))
		assert_equal( ['',16.25], parse_num( '010.1p1' ))
	end
### >>>
	def test_floats_nve
		assert_equal( ['-1',0.0], parse_num( '0x10e-1' )) # quirk!
		assert_equal( ['',0.0], parse_num( '0b10e-1' ))
		assert_equal( ['',0.0], parse_num( '0o10e-1' ))
		assert_equal( ['',0.0], parse_num( '010e-1' ))

		assert_equal( ['',0.0], parse_num( '0x10p-1' ))
		assert_equal( ['',0.0], parse_num( '0b10p-1' ))
		assert_equal( ['',0.0], parse_num( '0o10p-1' ))
		assert_equal( ['',0.0], parse_num( '010p-1' ))

		assert_equal( ['-1',0.0], parse_num( '0x10.1e-1' )) # quirk!
		assert_equal( ['',0.0], parse_num( '0b10.1e-1' ))
		assert_equal( ['',0.0], parse_num( '0o10.1e-1' ))
		assert_equal( ['',0.0], parse_num( '010.1e-1' ))

		assert_equal( ['',0.0], parse_num( '0x10.1p-1' ))
		assert_equal( ['',0.0], parse_num( '0b10.1p-1' ))
		assert_equal( ['',0.0], parse_num( '0o10.1p-1' ))
		assert_equal( ['',0.0], parse_num( '010.1p-1' ))
	end
	def test_floats_pve
		assert_equal( ['+1',0.0], parse_num( '0x10e+1' )) # quirk!
		assert_equal( ['',0.0], parse_num( '0b10e+1' ))
		assert_equal( ['',0.0], parse_num( '0o10e+1' ))
		assert_equal( ['',0.0], parse_num( '010e+1' ))

		assert_equal( ['',0.0], parse_num( '0x10p+1' ))
		assert_equal( ['',0.0], parse_num( '0b10p+1' ))
		assert_equal( ['',0.0], parse_num( '0o10p+1' ))
		assert_equal( ['',0.0], parse_num( '010p+1' ))

		assert_equal( ['+1',0.0], parse_num( '0x10.1e+1' )) # quirk!
		assert_equal( ['',0.0], parse_num( '0b10.1e+1' ))
		assert_equal( ['',0.0], parse_num( '0o10.1e+1' ))
		assert_equal( ['',0.0], parse_num( '010.1e+1' ))

		assert_equal( ['',0.0], parse_num( '0x10.1p+1' ))
		assert_equal( ['',0.0], parse_num( '0b10.1p+1' ))
		assert_equal( ['',0.0], parse_num( '0o10.1p+1' ))
		assert_equal( ['',0.0], parse_num( '010.1p+1' ))
	end
end
