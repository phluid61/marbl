
class MarblParser

=begin
	def parse_dq_string str, tree
		# todo: interpolation
		if m = /^"((\\.|[^\\"]+)*)"/.match(str)
			tree << MarblToken.new( :dq_string, m[1] )
			str[ m[0].length..-1 ]
		else
			raise MarblParseError, "wtf"
		end
	end
=end
	def parse_dq_string str, tree
		closed = false
		s = ''
		i = 1
		until (c=str[i,1]).empty?
			i += 1
			case c
			when '\\'
				d = str[i,1]
				i += 1
				case d
				when 'n'
					s << "\n"
				when 'r'
					s << "\r"
				when 't'
					s << "\t"
				when 'x'
					case e = str[i,1]
					when /[[:xdigit:]]/
						i += 1
						case f = str[i,1]
						when /[[:xdigit:]]/
							s << (e+f).to_i(16).chr
							i += 1
						else
							s << e.to_i(16).chr
						end
					else
						raise MarblParseError, "invalid hex escape"
					end
				when 'u'
					case e = str[i,1]
					when /[[:xdigit:]]/
						quad = str[i,4]
						raise MarblParseError, "invalid Unicode escape" unless quad =~ /[[:xdigit:]]{4}/
						s << eval(%Q("\\u{#{quad}}"))
						i += 4
					when '{'
						if m = /^{[[:xdigit:]]+}/.match(str[i..-1])
							s << eval(%Q("\\u#{m[0]}"))
							i += m[0].length
						else
							raise MarblParseError, "invalid Unicode escape"
						end
					else
						raise MarblParseError, "invalid Unicode escape"
					end
				when ''
					raise MarblParseError, "unexpected end of file in string"
				else
					s << d
				end
			when '"'
				case d = str[i,1]
				when '', /[^[:word:]]/
					closed = true
					break
				else
					raise MarblParseError, "unexpected `#{c}' after string"
				end
			else
				s << c
			end
		end
		raise MarblParseError, "unexpected end of file in string" unless closed
		tree << MarblToken.new( :sq_string, s )
		str[i..-1]
	end


	def parse_sq_string str, tree
		closed = false
		s = ''
		i = 1
		until (c=str[i,1]).empty?
			i += 1
			case c
			when '\\'
				d = str[i,1]
				i += 1
				#raise MarblParseError, "unexpected end of string" if d.empty?
				s << d
			when "'"
				case d = str[i,1]
				when '', /[^[:word:]]/
					closed = true
					break
				else
					raise MarblParseError, "unexpected `#{c}' after string"
				end
			else
				s << c
			end
		end
		raise MarblParseError, "unexpected end of string" unless closed
		tree << MarblToken.new( :sq_string, s )
		str[i..-1]
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

end

