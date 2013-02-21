require 'database'
require 'treetop'
require 'pry'
require 'language'

module Linguistics
###### Setup
	Link = Struct.new( "LinkParserLink", :lcon, :rcon, :length,:index)
###### Class Functions
	
	def self.load_parser
		Treetop.load File.join(File.dirname(__FILE__),'treetop/linguisticsparser')
		@parser = LinguisticsParser.new
	end
	def self.parse(string)
		return @parser.parse(string)
	end
	def self.parser
		@parser
	end
	def self.parser=(input)
		@parser = input
	end
end

###########################
##### Linguistics Syntax Classes
class Linguistics::WordClass < Treetop::Runtime::SyntaxNode
######## Accessors ###################
	def connectors
		list_connectors
	end

	def list_connectors
		equation.list_connectors			
	end	
	
	def links
		(list_connectors.collect { |con| con.links }).flatten
	end

	# Generate an independent copy of the wordclass
	def copy
		Linguistics.parse(text_value) 	#TODO: We don't actually care about the equation we can just
						# 	 directly copy the disjunct sets and generate copies of the connectors
	end
	
	# Generates a set of disjuncts for the wordclass
	def disjuncts
		@disjuncts ||= equation.disjuncts.sort do |d1,d2| 
			d1.inject(0) { |r,e| r + e.cost } <=>  d2.inject(0) { |r,e| r + e.cost }
		end
	end
###########################

	def delete_pairing!
		list_connectors.each {|con| con.delete_pairing! }
	end

##########################
# These check validity of connector states DEPRECIATED should still work?
	def sat?
		equation.sat?
	end
	def valid?
		equation.valid?
	end
##############

	def inspect
		"#<#{self.class} : \"#{text_value}\" >"
	end
end

class Linguistics::Connector < Treetop::Runtime::SyntaxNode
####### General ################
	def inspect
		"#<#{self.class} : \"#{text_value}\" >"
	end
	def list_connectors
		[self]
	end
################################
# Post generation support functions

	def add_link(link)
		(@links ||= []).push(link)
	end
	def links
		@links ||= []
	end

#################################
# Support functions for Linkage generation
	def cost
		return @cost unless @cost.nil? 
		@cost = 0; p = parent
		until p.parent.nil? do
			@cost = @cost + 1 if p.is_a? ::Linguistics::CostNode
			p = p.parent
		end
		@cost
	end
	def wordclass
		return @wordclass unless @wordclass.nil? 
		@wordclass = self
		@wordclass = @wordclass.parent until @wordclass.is_a? Linguistics::WordClass
		@wordclass
	end

	def delete_pairing!
		@pairings = nil
	end

	# Pair this connector to another 
	def pair(other)
		raise "Cannot pair #{other} is not a valid partner" if !(other === self) or other.wordclass == self.wordclass
		self.add_partner(other)
		other.add_partner(self)
	end

	# Add to the set of pairs
	def add_partner(other)
		(@pairings ||= []).push other  
	end

	# Checks if this connector could match the other connector (ignores word validity)
	def ===(other)
		 (direction_match?(other,'+') ||  direction_match?(other,'-')) &&
		upper_match?(other) && lower_match?(other)  
		#matchs?(other,:forward) or matchs?(other,:backward) 
	rescue 
		raise "Failure comparing #{other} may not be a valid #{self.class}"
	end
	
	# Checks if the connector can form a valid link with the other connector
	# in_direction defined the direction the other connector is 
	# ( in the context of the sentence not its actual dictection.text_value )
	def matchs?(other,in_direction = nil)
		in_direction = self.direction.text_value if in_direction.nil?
		in_direction = {:forward => "+", "+" => "+", :backward => '-', '-' => '-'}[in_direction]
		direction_match?(other,in_direction)  && upper_match?(other) && 
		lower_match?(other) && (other.wordclass != self.wordclass) # Can't match to the same word
	end

	# Check that the signs of the respective connectors matches their relative word position
	def direction_match? other ,in_direction
		self.direction.text_value == in_direction	&& 
		!other.direction.nil?				&& 
		other.direction.text_value != in_direction  	
	end 
	
	# Are the Connectors of the same generic type?
	def upper_match? other
		other.type.text_value == self.type.text_value
	end
	
	# Do the subclasses of the connectors match? 
	def lower_match? other
		mine = (arb.text_value + misc.text_value).each_char.collect { |c| c }
		theirs = (other.arb.text_value + other.misc.text_value).each_char.collect { |c| c }
		((mine.length < theirs.length) ? mine : theirs ).length.times.inject(true) do |r,c|
			r && (mine[c] == theirs[c] || mine[c] == '*' || theirs[c] == '*')  
		end
	end

	# Set of all connectors paired to this connector
	def pairings
		@pairings ||= []
	end

	# Is this connector satisfied (i.e meets linkage requirements Y
	def sat?
		!pairings.empty? && (pairings.length == 1 || !multiple.nil?) && 
		pairings.all? { |k| self.matchs?(k) }
	end
	
	# If this connector isn't satisfied are any of the pairings an invalid match for this connector
	# usually translates to (sat? || pairings.empty?)
	def valid?	
		pairings.empty? || (pairings.length == 1 || !multiple.nil?) && 
		pairings.all? { |v| self.matchs?(v) && self.wordclass != v.wordclass}
	end

	def has_pairings?
		!pairings.empty?	
	end

	# The Set of all disjuncts of a single connector is itself
	def disjuncts
		[[self]] # Double nested because a Set of disjunsts is a set of sets of connectors
	end
###############################
end
###################### Treetop Parse Nodes ##############################
# Refer to Linguistics treetop file for how these nodes are instanciated
# These nodes are subnodes of a linguisitics equation used primarily for
# initial disjunct set creation

class Linguistics::DisjunctNode < Treetop::Runtime::SyntaxNode

	def list_connectors
		case
		when  	other_terms.empty? then [] 
		else 	other_terms.elements.collect {|t| t.term.list_connectors}
		end.flatten + start.list_connectors
	end
	def sat?
		start.sat? && start.valid? && 
		other_terms.elements.all? { |ele| (ele.empty?) ? true : (ele.term.sat? && ele.term.valid?)}
	end
	def valid?
		start.valid? && 
		other_terms.elements.all? { |ele| (ele.empty?) ? true : (ele.term.sat? && ele.term.valid?)}
	end
	def disjuncts
		start.disjuncts + other_terms.elements.collect { |e| e.term.disjuncts }.flatten(1) 
	end
end
class Linguistics::OperandsNode < Linguistics::DisjunctNode
	def sat?
		start.valid? && 	# All valid
		other_terms.elements.all? { |ele|  ele.empty? || ele.term.valid? }  && 
		( start.sat? || 	# Any term satisfied
			other_terms.elements.any? { |ele|  !ele.empty? && ele.term.sat? && ele.term.valid? }
			)
	end
	def disjuncts
		other_terms.elements.inject(start.disjuncts) do |r,e| 
			(r.product(e.term.disjuncts)).collect { |a| a.flatten }
		end
	end

end
class Linguistics::OptionalNode < Treetop::Runtime::SyntaxNode
	def list_connectors
		or_rule.list_connectors
	end
	def sat?
		or_rule.valid?
	end
	def disjuncts
		or_rule.disjuncts + [[]]
	end
end

class Linguistics::ParenNode < Treetop::Runtime::SyntaxNode
	def list_connectors
		content.nil? ? [] : content.list_connectors
	end
	def disjuncts
		(content.empty?) ?  [[]] : content.disjuncts
	end
end

class Linguistics::CostNode < Linguistics::ParenNode 
	def cost;  1; end
end
########################## END Treetop Parse Nodes #######################

class Linguistics::Sentence < Treetop::Runtime::SyntaxNode
# Linguistics::Sentence is a generic word relational system meant to be 
# inherited on a language by language basis. Provided functionality
# to generate Link Parser grammatical links as defined by the 
# Grammar selected by the individual words.
######################################
	public 
	##############################
	def words
		raise "Reached Linguistics version. must be overidden by including object"
	end
	def links
		@links
	end
	def link(index)
		@links[index]
	end	
	def resolve
		@resolve_status ||= disjunct_linkage_generate
	end

	#TODO: Remove this function as this isn't a parsing call so much as it is a compile
	def parse
		@parse_status ||= disjunct_linkage_generate
	end
####################################
	private
	###########################


	# This function is called on a successful generation of linkages and sets up the sentence 
	def set_linkages(possible_link_array)
		return :failed if possible_link_array.nil?
		whsh = {}
		words.length.times{ |i| words[i].wordclass = wordclasses[i]; whsh[wordclasses[i]] = i }
		@links = possible_link_array.collect do |con| 
			if con.direction.text_value == '+'
				con.pairings.collect { |p| Linguistics::Link.new(con,p, whsh[p.wordclass] - whsh[con.wordclass],whsh[con.wordclass])  }
			end
		end
	end
	def wordclasses
		@wordclasses ||= words.collect do |ele| 
			ele.is_a?(Linguistics::WordClass) ? ele.copy : ele.grammar_equation.copy
		end
	end

	# Internal function that generates the link_set if possible and sets @links
	# This function should be called directly by subclasses of Linguistic::Sentence in the resolve function
	def disjunct_linkage_generate
		dis_arr = 	wordclasses.collect { |wc| wc.disjuncts } # collection of disjunct arrays
		dis_arr = 	prune_disjuncts(dis_arr)		  # Prune disjuncts that can't exist
		# Use product to generate a list of all combinations of disjuncts that could work
		link_pool = 	dis_arr.inject([[]]) {|r,e| r.product(e).collect { |q| q.flatten } }
		link_list = 	select_from_link_pool(link_pool)
		set_linkages(link_list) # set the @links if links can be created
	end


	# Find a valid set of connectors from a pool of disjunct combinations. Link_pool should be the
	# set of all possible combinations of disjuncts (1 per word).
	def select_from_link_pool pool
		pool.each do |ll|
			wordclasses.each { |wc| wc.delete_pairing! } # Clean last connector list
			hsh = {} # hsh is used to subdivide connectors by type
			ll.each { |con| (hsh[con.type.text_value] ||= []).push con } # Generate hashing
			# Skip this pool if the first/last connector is in the wrong direction
			# or if there is only 1 connector
			next if hsh.any? {|k,v| v.length == 1 || 
						v[0].direction.text_value == '-'  || 
						v.last.direction.text_value == '+'}
			hsh.each { |k,v| _pair_sub_array(v) ; _pair_sub_array(v.reverse) }
			next if ll.any? { |con| !con.sat? || !con.valid? } || 
				!_valid_lengths?( ll.inject({}) do |h,c| # Generate index connector hash 
							h.merge!( { c => wordclasses.index(c.wordclass) } )  
							(h[h[c]] ||= []).push c
							h
						end
						)
			return ll
		end
		return nil
	end

	# Checks if a link set meets the length requirements (No crossing). list (lhsh) is passed as a index hash
	# so the connector's word can easily be identified. This function is recursive
	def _valid_lengths?(lhsh,bl = nil, fl = nil,chsh = nil)
		# if no bounds given generate default bounds
		bl = 0 if bl.nil?
		fl = wordclasses.length if fl.nil?  
		return true if ((bl+1)...fl).to_a.length < 2  
		# ^Recursive end case when the range of words being checking is empty 

		# If any of the words have connectors that point out of the valid range the result if invalid
		return false if ((bl+1)...fl).to_a.any? { |i| lhsh[i].any? { |con| 
					con.pairings.any? { |v| (v.direction.text_value == '+') ? lhsh[v] > fl : lhsh[v] < bl } } }

		# Create a dividing point to seperate the words into those inside the longest link and outside the
		# longest link
		new_fl = (lhsh[bl] ||= []).collect { |con| lhsh[con.pairings.max { |p| lhsh[p] }] }.max 
		return	_valid_lengths?( lhsh , bl, new_fl ) && _valid_lengths?(lhsh,new_fl,fl) # test both subsets	
	end

	# Support pairing function for a link_pool v is the list of connectors (assumed of the same type
	def _pair_sub_array v, id = '+'
		v.length.times do |i| 
			next if v[i].direction.text_value != id || (v[i].sat? && v[i].valid? && v[i].multiple.nil?)
			sd = 0; # Same Direction counter
			((i+1)...(v.length)).each do |ip|
				case 
					when v[ip].direction.text_value == id then sd = sd + 1
					when sd > 0 then sd = sd - 1
					when sd == 0 
						v[i].pair(v[ip]) if v[i].matchs?(v[ip],id) && 
									(!v[ip].sat? || v[ip].multiple.nil?) 
						break if v[i].multiple.nil?
				end
			end 
		end
	end


	# Prunes disjuncts that are unlikely to generate valid results (i.e the disjunct has no possible match)
	def prune_disjuncts dis_arr
		did_prune = true
		while did_prune do
			did_prune = false
			chsh = {}
			dis_arr.each do |wc| # wc => all disjuncts for a word class 
				wc.each do |dis| # dis a single disjunct set 
					dis.each { |con| (chsh[con.type.text_value] ||= []).push con }
				end
			end
			if chsh.any? {|k,v| v.length < 2}
				did_prune = true
				dis_arr.each do |wc| 
					wc.delete_if do |dis| 
						dis.any? { |con| chsh[con.type.text_value].length < 2 } 
					end
				end
			end
		end
		dis_arr
	end

end
