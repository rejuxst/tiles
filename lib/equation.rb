class Equation
	def self.from_string(string)
		ary = parse(string)
	end
	def resolve
	end
	def self.parse(string)
		sub_divided = []
		temp = ""
		string.each_char do |char|
			#binding.pry
			case char
				when /[\w,\d,#]/ 			then temp << char
				when /[\*,%,-,+,\/,\\,\^,(,)]/ 	then sub_divided.push(temp.clone); sub_divided.push(char);temp.clear
				when /\s/			then sub_divided.unshift(temp.clone);temp.clear
				else raise SyntaxError, "Invalid Character encountered in equation #{char}"
			end
		end
		sub_divided.push temp.clone unless temp.empty?
		return sub_divided
	end
	def initialize(target)
		
	end
	class BasicOperation
		def initialize(target,operator,collection)
			@operator = operator
			@collection = collection.collect { |i| (i.is_a?(Literal) or i.is_a?(Variable))?  i : Equation.create_element(target,i)}
		end
		def resolve
			temp = @collection.collect{|item| item.resolve }
			start = temp.pop
			temp.each {|item| start = start.send(operator,item)}
		end
	end
	class Variable
		def initialize(target,value)
			@target = target
			@value = value
		end
		def resolve
			@target[@value]
		end
	end
	class Literal
		def initialize(value)
			@value = value
		end
		def resolve
			@value
		end
	end
end

