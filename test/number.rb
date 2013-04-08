#TODO: test errors!

require 'test/unit'
$VERBOSE = true

require_relative '../token'
require_relative '../errors'
require_relative '../parser/number'

$parser = MarblParser.new
def parse_num n
	t = []
	s = $parser.parse_number( n, t )
	[s, t[0].value.to_f]
end

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
	def test_floats_nve
		assert_equal( ['-1',270.0], parse_num( '0x10e-1' )) # quirk!
		assert_equal( ['',0.2], parse_num( '0b10e-1' ))
		assert_equal( ['',0.8], parse_num( '0o10e-1' ))
		assert_equal( ['',0.8], parse_num( '010e-1' ))

		assert_equal( ['',8.0], parse_num( '0x10p-1' ))
		assert_equal( ['',1.0], parse_num( '0b10p-1' ))
		assert_equal( ['',4.0], parse_num( '0o10p-1' ))
		assert_equal( ['',4.0], parse_num( '010p-1' ))

		assert_equal( ['-1',16.1171875], parse_num( '0x10.1e-1' )) # quirk!
		assert_equal( ['',0.25], parse_num( '0b10.1e-1' ))
		assert_equal( ['',0.8125], parse_num( '0o10.1e-1' ))
		assert_equal( ['',0.8125], parse_num( '010.1e-1' ))

		assert_equal( ['',8.03125], parse_num( '0x10.1p-1' ))
		assert_equal( ['',1.25], parse_num( '0b10.1p-1' ))
		assert_equal( ['',4.0625], parse_num( '0o10.1p-1' ))
		assert_equal( ['',4.0625], parse_num( '010.1p-1' ))
	end
	def test_floats_pve
		assert_equal( ['+1',270.0], parse_num( '0x10e+1' )) # quirk!
		assert_equal( ['',20.0], parse_num( '0b10e+1' ))
		assert_equal( ['',80.0], parse_num( '0o10e+1' ))
		assert_equal( ['',80.0], parse_num( '010e+1' ))

		assert_equal( ['',32.0], parse_num( '0x10p+1' ))
		assert_equal( ['',4.0], parse_num( '0b10p+1' ))
		assert_equal( ['',16.0], parse_num( '0o10p+1' ))
		assert_equal( ['',16.0], parse_num( '010p+1' ))

		assert_equal( ['+1',16.1171875], parse_num( '0x10.1e+1' )) # quirk!
		assert_equal( ['',25.0], parse_num( '0b10.1e+1' ))
		assert_equal( ['',81.25], parse_num( '0o10.1e+1' ))
		assert_equal( ['',81.25], parse_num( '010.1e+1' ))

		assert_equal( ['',32.125], parse_num( '0x10.1p+1' ))
		assert_equal( ['',5.0], parse_num( '0b10.1p+1' ))
		assert_equal( ['',16.25], parse_num( '0o10.1p+1' ))
		assert_equal( ['',16.25], parse_num( '010.1p+1' ))
	end
end

