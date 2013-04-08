
class MarblParser

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

end

