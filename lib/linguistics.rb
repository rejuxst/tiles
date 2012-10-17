require 'pry'
class Linguistics
# NOTE development was based upon papers used to develop the LinkParser Gem 
# Lingusitics Class defines basic syntax primitives for parsing languages:
# NOTE This was implemented with English in mind
Struct.new(:connector,:back,:forward,:type)
class WordClass
# Each Word is linked to other words via connectors
# equation format
	attr_reader :connectors
	attr_reader :equation,:name
	def self.create_wordclass(classname,equation)
		return WordClass.new(classname,equation)
	end
	def get_tree()
		return @ctree
	end
	def initialize(classname,equation)
		@name = classname.to_s
		@ctree = ConnectorTree.new(equation)
		@equation = equation
		return self
	end
	def list_links
		output = []
                equ = ''
                @equation.each_char do |c|
			 equ << ( (c.match(/[{,},(,)]/))? " #{c} " : c ) 
		end
		equ.split(" ").each { |ele| output.push ele if (ele=~ /(and|or|[{,},(,)])/).nil?}
		return output
	end

	def sat?(con_array) 
		return @ctree.sat?(con_array)
	end
end #end WordClass
class Connector
# Connectors within a word follow 3 rules:
# Planarity: 	The links do not cross (when drawn above the word)
# Connectivity: The links suffice to connect all the words of the sequence together.
# Satisfaction: The links satisfy the linking requirements of each word in the sequence
	attr_accessor :back
	attr_accessor :forward
	attr_accessor :type
	def initialize(b,f,t)
		@back = b
		@forward = f
		@type = t
	end
	def match?(string)
		return ("#{@type.downcase}+" == string.downcase) ||("#{@type.downcase}-" == string.downcase) 
	end
end #end Connector
class Word
#organize using ports?
### Organizational keys
	attr_accessor  :forward	# next word in the sentence nil if the end of the sentence
	attr_accessor :previous	# Previous word in the sentence nil if the beginning of the sentence
	attr_accessor :sentence	# Pointer to the sentence which contains this word
###
	attr_reader :word
	attr_reader :wordclass
	attr_reader :connectors
	def initialize(wordclass,word)
		@connectors = []
		raise "Invalid inputs wordclass is a #{wordclass.class} and word is a #{word.class}" unless wordclass.class <= WordClass and word.class <= String
		@wordclass = wordclass
		@word = word
	end
	def list_links
		@wordclass.list_links
	end
	def delete_connectors
		@connectors = []
	end
	def add_connector(con)
		@connectors.push con
	end
	def equation_satisfied?
		@wordclass.sat?(@connectors)
	end
end
class Sentence
# Maybe make a table of all the possible Connectors and find first set to satisfy solution
# Remeber to generate the list of Connectors such that they satisfy the Planarity rulen
### Organizational Keys
	attr_reader :forward
	attr_reader :previous
	attr_reader :script
###
	attr_reader :words
	def self.from_string(string,dictionary = nil)
		raise "Need a valid dictionary" if dictionary.nil?
		arr = string.split(/[\., ]/).collect { |s| s.downcase }
 	        output = Linguistics::Sentence.new
          	arr.each {|word| output.add_word Word.new(dictionary[word],word) }
          	return output
	end
	def initialize(array = [],script = nil, f = nil, p = nil)
		@forward = f
		@script = script
		@previous = p
		@words = array
	end
	def add_word(w)
		raise "Not a word #{w}" unless w.class <= Word 
		w.sentence = self
		w.previous = @words.last
		@words.last.forward = w unless @words.empty?
		@words<< w
	rescue
		binding.pry
	end
	def <<(word)
		add_word(word)
	end
	def to_string()
		array = @words.collect {|w| "#{w.word}"}
		return array.join(" ")
	end
	def create_linkages_table()
		link_list = []
		# Generate All possible combintations
		(0..(@words.length-1)).each do |outer|
		(0..(@words.length-1)).each do |inner|
			next if outer >= inner
			oconn = @words[outer].list_links
			iconn = @words[inner].list_links
			oconn.each do |ostr|
			ostr.scan /(\w*)\+/ do |match|
				#@words[ele[0]].add_connector("ele[2]+")
				match = match[0]
				matches = (iconn.collect { |io| io =~ /(#{match})-/ ; $1}).delete_if { |e| e == nil }
				#link_list.push Connector.new(@words[outer],@words[inner],match) unless matches.empty?
				link_list.push [outer, inner, match] unless matches.empty? # Generate Tuples for Word Pair
				#puts "Link: #{@words[outer].word} | #{@words[inner].word} : #{match}" unless matches.empty?
			end
			end
		end
		end	
		return link_list	
	end
	def resolve
		link_list = create_linkages_table	
		puts "Resolving A Sentence with #{@words.length} words, and #{link_list.length} links"
		((@words.length-1)..(link_list.length)).each do |i|
			puts "\tTrying #{i} link combinations:"
			link_list.combination(i) do |possible_link_array|
				@words.each{|w| w.delete_connectors}
				puts "\t\t#{possible_link_array}"
				possible_link_array.each do |ele|
					@words[ele[0]].add_connector(Connector.new(ele[0],ele[1],ele[2]))
					@words[ele[1]].add_connector(Connector.new(ele[0],ele[1],ele[2]))
				end 
				valid = true
				begin
				# Checking thats the connectors are valid.
					all_connected = true
					all_ordered = true
					equation_sat = true
					## Does every Word have a connector?
					@words.each {|w| all_connected = false if w.connectors.empty?}
					## Is every connection in valid order?
					(0..(@words.length-1)).each do |i| # forward check every word
						@words[i].connectors.each do |con| # forward check every connector in every word
							mf = con.forward
							(i..(mf-1)).each do |m| # if any connector on any word between the ports
										# Crosses over the max_forward value invalid connect
								@words[m].connectors.index {|c| all_ordered = false if c.forward > mf}
							end
						end
					end
					## is every equation satisfied?
					@words.each {|w| equation_sat = false unless w.equation_satisfied?() }
					#binding.pry
					valid =  all_connected and all_ordered and equation_sat
				rescue
					binding.pry
				end
				puts "The Link combination is valid" if valid
				return true if valid
			end
		end
		return false
	end
end #end Sentence
class ConnectorTree
	attr_accessor :tree	
	attr_accessor :connector_list
	Node = Struct.new("Node",:type,:data,:cnt,:any,:sat)
	def initialize(equation)
		@equation = equation
                @tree = parse_equation(equation)
        end
	def orig_equation
		return @equation
	end
	def sat?(con_array)
		puts "Attempting to satisfy #{@equation} with \n\t #{con_array}"
		if(@tree.class <= String)
			i = con_array.index{ |c| c.match?(@tree)}
			output = !i.nil?
		else
			output = resolve_node(@tree,con_array)
		end
		puts "\tEquation is satified? #{output}"
		return output
	end
	def resolve_node(node,con_array)
		output = :empty
		type = node.type
		results = []
		return true if node.data.length == 1 && node.any
		node.data.each do |d|
			if(d.class <= String) 
				i = con_array.index{ |c| c.match?(d)}
				results << !i.nil?	
			else
				results << resolve_node(d,con_array)
			end
		end
		results.each do |r| 
			results[0] = results[0] && r if type == :and && !(node.any)
			results[0] = results[0] || r if type == :or
			results[0] = results[0] ^  r if type == :and && (node.any) 
			# ^If the node is any we can't allow partial connections only full connections
		end
		#binding.pry
		return results[0]
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
				# when /or/
				# raise "Missing operant to or. Last term was #{previous}"  if ptype != :data 
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
	def list_links(input = @tree)
		return [input] if input.class == String
		output = []
		input.data.each do |d|
			list_links(d).each{|gen| output.push gen}
		end	
		return output
	end

end #end Connector Tree
end #end Linguistics
