
require 'test/unit'
$VERBOSE = true

require_relative '../token'
require_relative '../errors'
require_relative '../parser/operator'

$parser = MarblParser.new
def parse_operator n
	t = []
	s = $parser.parse_operator( n, t )
	[s, t[0].value]
end

class Test_parser < Test::Unit::TestCase
	def test_dec_ints
		assert_equal( ['','.'], parse_operator( '.' ) )
		assert_equal( ['','..'], parse_operator( '..' ) )
		assert_equal( ['','.....'], parse_operator( '.....' ) )
		assert_equal( ['','+'], parse_operator( '+' ) )
		assert_equal( ['','+-*/!@'], parse_operator( '+-*/!@' ) )
		assert_equal( ['foo','.'], parse_operator( '.foo' ) )
		assert_equal( ['[]','.'], parse_operator( '.[]' ) )
		assert_equal( ['.---','+++'], parse_operator( '+++.---' ) )
	end
end

