
class MarblParser

	def parse_line_comment str, tree
		m = /^#(.*)(\n|$)/.match str
		tree << MarblToken.new( :line_comment, m[1] )
		str[ m[0].length..-1 ]
	end

end

