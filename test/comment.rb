
require 'test/unit'
$VERBOSE = true

require_relative '../token'
require_relative '../errors'
require_relative '../parser/comment'

$parser = MarblParser.new
def parse_line_comment s
	t = []
	s = $parser.parse_line_comment( s, t )
	[s, t[0].value]
end

class Test_parser < Test::Unit::TestCase
	def test_parse_line_comment
		assert_equal( ['',''], parse_line_comment( '#' ))
		assert_equal( ['','#foo'], parse_line_comment( '##foo' ))
		assert_equal( ['foo',''], parse_line_comment( "\#\nfoo" ))
		assert_equal( ['bar','foo'], parse_line_comment( "\#foo\nbar" ))
	end
end

