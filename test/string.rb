
require 'test/unit'
$VERBOSE = true

require_relative '../token'
require_relative '../errors'
require_relative '../parser/string'

$parser = MarblParser.new
def parse_sq_string s
	t = []
	s = $parser.parse_sq_string( s, t )
	[s, t[0].value]
end
def parse_dq_string s
	t = []
	s = $parser.parse_dq_string( s, t )
	[s, t[0].value]
end
def parse_symbol s
	t = []
	s = $parser.parse_symbol( s, t )
	[s, t[0].value.value]
end

class Test_parser < Test::Unit::TestCase
	def test_parse_sq_string
		assert_equal( ['',''], parse_sq_string( %q[''] ))
		assert_equal( [' ',''], parse_sq_string( %q['' ] ))
		assert_raise(MarblParseError) { parse_sq_string( %q[''x] ) }
		assert_equal( ['', 'x'], parse_sq_string( %q['x'] ))
		assert_equal( ['.y','x'], parse_sq_string( %q['x'.y] ))
		assert_equal( ['','"'], parse_sq_string( %q['"'] ))
		assert_equal( ['',%q[\\]], parse_sq_string( %q['\\\\'] ))
		assert_equal( ['',%q[']], parse_sq_string( %q['\''] ))
		assert_equal( ['',%q[\\']], parse_sq_string( %q['\\\\\''] ))
		assert_equal( ['',%q[hello world]], parse_sq_string( %q['hello\ world'] ))
	end
	def test_parse_dq_string
		assert_equal( ['',''], parse_dq_string( %q[""] ))
		assert_equal( [' ',''], parse_dq_string( %q["" ] ))
		assert_raise(MarblParseError) { parse_dq_string( %q[""x] ) }
		assert_equal( ['', 'x'], parse_dq_string( %q["x"] ))
		assert_equal( ['.y','x'], parse_dq_string( %q["x".y] ))
		assert_equal( ['',%q[']], parse_dq_string( %q["'"] ))
		assert_equal( ['',%q[\\]], parse_dq_string( %q["\\\\"] ))
		assert_equal( ['',%q["]], parse_dq_string( %q["\""] ))
		assert_equal( ['',%q[\\"]], parse_dq_string( %q["\\\\\""] ))
		assert_equal( ['',%Q[\thello world\n\t34\u1234A]], parse_dq_string( %q["\thello\ world\n\x9\x334\u1234\u{41}"] ))
	end
	def test_parse_symbol
		assert_equal( ['','x'], parse_symbol( %q[:x] ))
		assert_equal( [' ','x'], parse_symbol( %q[:x ] ))
		assert_equal( ['.y','x'], parse_symbol( %q[:x.y] ))
		assert_equal( ['','x'], parse_symbol( %q[:"x"] ))
		assert_equal( ['','x'], parse_symbol( %q[:'x'] ))
		assert_equal( ['','A'], parse_symbol( %q[:"\x41"] ))
	end
end

