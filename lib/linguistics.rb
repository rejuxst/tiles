require 'pry'
class Linguistics
# NOTE development was based upon papers used to develop the LinkParser Gem 
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
end #end ConnectorClass
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
		@ctree = ConnectorTree.new(equation)
		return self
	end
end #end WordClass
class Connector
# Connectors within a word follow 3 rules:
# Planarity: 	The links do not cross (when drawn above the word)
# Connectivity: The links suffice to connect all the words of the sequence together.
# Satisfaction: The links satisfy the linking requirements of each word in the sequence
	attr_accessor 	:source
	attr_accessor 	:name
	attr_accessor	:type
	def self.from_equation(eqname,source_equation)
		c = Connector.new
		c.type = eqname[-1]
		c.name = eqname.delete '-+' 
		c.source = source_equation
		return c
	end
end #end Connector
class Word
	attr_reader :word
	attr_reader :wordclass
	attr_reader :connectors
	def initialize(wordclass,word)
		@wordclass = worclass
		@word = word
		@connectors = wordclass.gen_connectors()
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
	def create_linkages_table()
		connector_list = []
		@words.each {|w| connector_list = connector_list + w.connectors}
		
	end
end #end Sentence
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
		output = {:type => nil, :up => nil, :terms => []}
		raise "Not enough terms in #{array} of #{orig_equation}" if array.last == 'and' or array.last == 'or'
		(output[:terms] << array[0] and return output) if array.length == 1
                while !(p = array.pop).nil?
                        item = case p
                                when "and"
				raise "multiple operations applied incorrectly #{array} in #{orig_equation}" unless output[:type].nil?
				output[:type] = :and
				nil
                                when "or"
				raise "multiple operations applied incorrectly #{array} in #{orig_equation}" unless output[:type].nil?
				output[:type] = :or
				nil
				when "(","{"
					a2 = [];cnt = 1;
					while cnt > 0
						raise "Missing closing #{p} in #{orig_equation}" if array.empty?
						cnt = cnt + 1 if array.last.match(/[(,{]/)
						cnt = cnt - 1 if array.last.match(/[),}]/) 
						a2.push(array.pop) if cnt > 0
					end
					array.pop	# Get Rid of the last } or )
					unless p == "{"
						temp = generate_equation_tree(a2.reverse)
						temp[:up] = output
						temp
					else
						{:type => :any, :up => output, :terms => [generate_equation_tree(a2.reverse)]}
					end
                                when ")","}"
					raise "Missing closing #{p} in #{orig_equation}"
	                        else
					p
                        end
			if !item.nil? && output[:terms].length == 2 	
				raise "Encountered extraneous input in equation #{orig_equation}" 
			end
			output[:terms] << item unless item.nil?
                end
		raise "Parse error in equation in #{orig_equation}" if output[:type].nil? || output[:terms].empty? 
		return output
	end
	def gen_connectors(input = @tree)
		output = []
		input[:terms].each do |t|
			temp =  [Connector.from_equation(t,input)] if t.class <= String
			temp = gen_connectors(t) if t.class <= Hash
			output = output + temp
		end
		return output
	end
	def swap!()
		output = {:any => [], :rest => []}
		temp = @tree
		# Initialize swap
		# Do a Swap	
	end
end #end Connector Tree
end #end Linguistics
