
class MarblParser

	def parse_operator str, tree
		if op_dots = /^\.+/.match(str)
			op = op_dots[0]
		elsif op_graph = /^[:graph:]+/.match(str)
			op = op_graph[0]
			if op_nonword = /^[^[:word:].]+/.match(op) # fixme: include '.' here?
				op = op_nonword[0]
			end
		else
			raise MarblParseError, "wtf" unless closed
		end
		tree << MarblToken.new( :operator, op )
		str[op.length..-1]
	end

end

