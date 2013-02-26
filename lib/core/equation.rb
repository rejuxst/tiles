require 'pry'
require 'treetop'
require 'polyglot'
require 'grammars/equationparser.treetop'
module MathEquation
	class Equation  < Treetop::Runtime::SyntaxNode	
		def value
			additive.value
		end
		def source=(input)
			@source = input
		end
		def source
			@source
		end
		def has_target?
			!output.empty?
		end
		def target
			output.target if !output.empty?
		end
		def target_value
			target.value(@source) if !output.empty?
		end
	end
	class Operation < Treetop::Runtime::SyntaxNode
		def value
			other_terms.elements.inject(start.value) do |res,ele| 
				res.send(ele.operator.text_value,ele.term.value) 
			end
		end
		def source
			parent.source
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
		def source
			parent.source
		end
	end
	class Variable < Treetop::Runtime::SyntaxNode
			def is_variable?
				true
			end
			def is_literal?
				false
			end
			def value(src = nil)
			text_value.strip.split('#').inject(src || parent.source) do |res,ele| 
				res[ele] unless res.nil?  
			end || default.to.value
			rescue 
				nil
			end
	end
end
class Equation
	@@parser = MathEquationParser.new
	def initialize(string)
		@equation = @@parser.parse(string)
	end
	def source=(src)
		@equation.source = src
	end
	def parse_failure?
		!@equation.nil?
	end
	def resolve
		unless @equation.has_target?
			@equation.value
		else
			raise "No Source database given for equation with output" if @equation.source.nil?
			@equation.target_value.set @equation.value
		end
	end
	def to_s
		@equation.text_value
	end
	def self.last_failure_reason
		return @@parser.failure_reason
	end
end
class Effect < Equation
	def resolve(src)
		self.source = src
		super()
	end
end
