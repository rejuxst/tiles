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
			when '-','<','left'  then -1
			when '+','>','right' then 1
			else 	raise "Invalid Connector Class Direction #{direction} for #{self}"
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
	def list_connectors
		@ctree.list_connectors
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
	attr_accessor   :target
	def self.from_equation(eqname,source_equation)
		c = Connector.new
		c.type = eqname[-1]
		c.name = eqname.delete '-+' 
		c.source = source_equation
		return c
	end
	def initialize(csrc,ctar,connclass) 
		@source = csrc
		@target = ctar
		@type   = connclass
	end
end #end Connector
class Word
	attr_reader :word
	attr_reader :wordclass
	attr_reader :connectors
	def initialize(wordclass,word)
		raise "Invalid inputs wordclass is a #{wordclass.class} and word is a #{word.class}" unless wordclass.class <= WordClass and word.class <= String
		@wordclass = wordclass
		@word = word
	end
	def list_connectors
		@wordclass.list_connectors
	end
end
class Sentence
# Maybe make a table of all the possible Connectors and find first set to satisfy solution
# Remeber to generate the list of Connectors such that they satisfy the Planarity rulen
	attr_reader :words
	def initialize(array = [])
		@words = array
		@words.each {|w| connector_list.push w.list_connectors }
	end
	def add_word(word)
		@words<< word
	end
	def <<(word)
		add_word(word)
	end
	def create_linkages_table()
		link_list = []
		# Generate All possible combintations
		(0..(@words.length-1)).each do |outer|
		(0..(@words.length-1)).each do |inner|
			next if outer >= inner
			oconn = @words[outer].list_connectors
			iconn = @words[inner].list_connectors
			oconn.each do |ostr|
			ostr.scan /(\w*)\+/ do |match|
				match = match[0]
				matches = (iconn.collect { |io| io =~ /(#{match})-/ ; $1}).delete_if { |e| e == nil }
				link_list.push Connector.new(@words[outer],@words[inner],match) unless matches.empty?
			end
			end
		end
		end	
		return link_list	
	end
	def resolve
		link_list = create_linkages_table	
		
	end
end #end Sentence
class ConnectorTree
	attr_accessor :tree	
	Node = Struct.new("Node",:type,:data,:cnt,:any,:sat)
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
        def generate_equation_tree(array, bracket = nil)
		node = Node.new
		node.any = (bracket =="{")?true : false
		node.data = []
		previous = nil
		ptype = nil
		while  ele = array.pop
			etype = case ele
				when /and/,/or/
					raise "Missing operant to #{ele}. Last term was #{previous}" if ptype == :operator 
					if node.type.nil? || node.type == ele.to_sym
						node.type = ele.to_sym 
					else
						raise "Does not support order of operations (encountered conflicting operators). Explicitly bracket"
					end	
					:operator
				#when /or/
				#	raise "Missing operant to or. Last term was #{previous}"  if ptype != :data 
				when /(\w*)\+/, /(\w*)\-/
					node.data.push ele
					:data
				when /[),}]/
					if (bracket == "{" && ele != "}") || (bracket == "(" && ele != ")") 
						raise "Unexpected bracket: #{ele}. operation began with #{bracket}."
					end
					return node unless node.type.nil? and !(node.any && node.data.length == 1)
					return node.data[0] unless node.data.empty?
					raise "Empty Brackets"
					:closing
				when /[(,{]/
					node.data.push generate_equation_tree(array,ele)
					:opening	
			end
			#puts "#{ele} was of type #{etype}"
			previous = ele; ptype = etype
		end
		return node unless node.type.nil?
		return node.data[0] unless node.data.empty?
		raise "Empty equation"
	end
	def list_connectors(input = @tree)
		return [input] if input.class == String
		output = []
		input.data.each do |d|
			list_connectors(d).each{|gen| output.push gen}
		end	
		return output
	end

end #end Connector Tree
end #end Linguistics
