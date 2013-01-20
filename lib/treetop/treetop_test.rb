require 'pry'
require 'treetop'
module MathEquation
	class OperationNode < Treetop::Runtime::SyntaxNode
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
Treetop.load 'equationparser'
parser = MathEquationParser.new
a = parser.parse '(1 + 1)'
binding.pry

