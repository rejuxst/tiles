require 'pry'
class Linguistics
# NOTE development was based upon papers used to develop the LinkParser Gem 
#
# Lingusitics Class defines basic syntax primitives for parsing languages:
# NOTE This was implemented with English in mind
class ConnectorClass
	attr_reader :direction
	attr_reader :name
	def self.create_connectorclass(name)
		
	end
	def initialize(name,direction)
		@direction = case direction
			when '-','<','left'
				-1
			when '+','>','right'
				1
			else
				raise "Invalid Connector Class Direction #{direction} for #{self}"
				nil
		end
		@name = name 
	end
end
class WordClass
# Each Word is linked to other words via connectors
# equation format
	attr_reader :connectors
	attr_reader :equation,:name
	def self.create_wordclass(classname,equation)
		return WordClass.new(classname,equation)
	end
	def initialize(classname,equation)
		@name = classname.to_s
		equ = ''
		equation.each_char{|c| equ << ( (c.match(/[{,},(,)]/))? " #{c} " : c ) }
		parse_equation(equ)
		return self
	end
	def parse_equation(equation)
		equ = ''
		equation.each_char{|c| equ << ( (c.match(/[{,},(,)]/))? " #{c} " : c ) }	
		generate_equation_tree(equ.split(" "))
	end
	def generate_equation_tree(array)
		p1 = nil
		p2 = nil
		type = nil
		array.for_each do |p|
			case p
				when "and"
				when "or"
				when "("
					cp = parse_equation(array)
				when ")"
				when "{","}"
				else
			end
		end

	end
	def find_partners()
		w = @word
		i = 0
		while 1
		w = case @type
			when '+'
				w.previous
			when '-'
				w.next
			else
				raise "Invalid Type for #{self.class}"
		end
		i = i + 1
		break if w == nil
		partners[i] =  w if w.matching_connector?(self)
		end
		return !partners.empty?
	end
	def matching_connector?(input)
		connectors.for_each {|c| return true if (input.type != c.type) && (c.name == input.name)}
		return false
	end

end
class Connector
# Connectors within a word follow 3 rules:
# Planarity: 	The links do not cross (when drawn above the word)
# Connectivity: The links suffice to connect all the words of the sequence together.
# Satisfaction: The links satisfy the linking requirements of each word in the sequence
	attr_reader 	:type
	attr_reader 	:name
	attr_reader 	:word
	attr_accessor 	:partners
	def initialize(nam,wor,typ)
		raise "Invalid Type for #{self.class}" if typ != '-' or typ != '+'
		@type = typ
		@name = nam
		@word = wor
		@partners = []
	end
	def find_partners()
		w = @word
		i = 0
		while 1
		w = case @type
			when '+'
				w.previous
			when '-'
				w.next
			else
				raise "Invalid Type for #{self.class}"
		end
		i = i + 1
		break if w == nil
		partners[i] =  w if w.matching_connector?(self)
		end
		return !partners.empty?
	end
	
end
class Sentence
	attr_reader :words
	def initalize()
		@words = []
	end
	def add_word(word)
		@words << word
	end
	def <<(word)
		add_word(word)
	end
	def create_linkages()

	end
end
class ConnectorTree
	attr_accessor :tree	
	def initialize(equation)
		@equation = equation
                @tree = parse_equation(equation)
        end
	def orig_equation
		return @equation
	end
        def parse_equation(equation)
                equ = ''
                equation.each_char do |c|
			 equ << ( (c.match(/[{,},(,)]/))? " #{c} " : c ) 
		end
                generate_equation_tree(equ.split(" ").reverse)
        end
        def generate_equation_tree(array)
                p1 = nil
                p2 = nil
                type = nil

                while !(p = array.pop).nil?
			puts p
                        item = case p
                                when "and"
					p1 = item
					type = :and
					nil
                                when "or"
					p1 = item
					type = :or
					nil
				when "(","{"
					a2 = [];cnt = 1;
					while cnt > 0
						raise "Missing closing #{p} in #{orig_equation}" if array.empty?
						cnt = cnt + 1 if array.last.match(/[(,{]/)
						cnt = cnt - 1 if array.last.match(/[),}]/) 
						a2.push(array.pop) if cnt > 0
					end
					array.pop	# Get Rid of the last )
                                        puts "Recusion=> #{a2}"	
					unless p == "{"
						generate_equation_tree(a2.reverse)
					else
						{:type => :any, :p1 => generate_equation_tree(a2.reverse), :p2 => nil}
					end
                                when ")","}"
					raise "Missing closing #{p} in #{orig_equation}"
	                        else
					p
                        end
			unless array.empty? || item.nil? || p1.nil?	
				raise "Encountered extraneous input in equation #{orig_equation}" 
			end
			p1 = item if p1.nil? && item.class == Hash
			p2 = item unless p1.nil?
                end
		raise "Parse error in equation in #{orig_equation}" if ((p2 == nil)&&(type != :any)) || (p1 == nil) 
		return {:type => type, :p1 => p1, :p2 => p2}
        rescue
		binding.pry
		raise
	end
end
end
