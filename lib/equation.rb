require 'treetop'

module MathEquation
	class Equation  < Treetop::Runtime::SyntaxNode	
		def value
			additive.value
		end
		def source=(input)
			@source = input
		end
	end
	class Operation < Treetop::Runtime::SyntaxNode
		def value
			other_terms.elements.inject(start.value) do |res,ele| 
				res.send(ele.operator.text_value,ele.term.value) 
			end
		end
	end
	class Literal < Treetop::Runtime::SyntaxNode
		def is_literal?
			true
		end
		def is_variable?
			false
		end
		def value
			text_value.to_i
		end
	end
	class Variable < Treetop::Runtime::SyntaxNode
			def is_variable?
				true
			end
			def is_literal?
				false
			end
			def value
				@source[text_value]
			end
	end
end
class Equation
	Treetop.load File.join(File.dirname(__FILE__),'treetop/equationparser')
	@@parser = MathEquationParser.new
	def initialize(string)
		@equation = @@parser.parse(string)
	end
	def source=(src)
		@source = src
	end
	def resolve
		return @equation.value
	end
	def self.last_failure_reason
		return @@parser.failure_reason
	end
end

