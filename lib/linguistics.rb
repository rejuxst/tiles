require 'database'
require 'treetop'
require 'pry'
class Language
	def self.load_parser
		Treetop.load File.join(File.dirname(__FILE__),"lang/#{self.name.downcase}parser")
		@parser = eval("#{self.name}LanguageParser.new")
	end
	def self.parse(string)
		return @parser.parse(string)
	end
	def self.parser
		@parser
	end
	def self.inherited(subclass)
		subclass.load_parser
	end
	class Grammar
		extend Database	
		def self.add_class(wordclass,equation)
			add_reference(wordclass,equation) {|src,tar| ::Linguistics.parse(tar)}
		end
		def self.[]=(key,value)
			add_class(key,value)
		end	
	end
end
class Language::Word < Treetop::Runtime::SyntaxNode
	attr_accessor :wordclass
	def self.set_language(lang)
		@language ||= lang
	end
	def self.language
		@language
	end
	def get_dictionary_entry
		self.class.language::Dictionary[word.strip]
	end
	def get_grammar_entry
		get_dictionary_entry.grammar
	end
	def grammar_equation
		Linguistics.parse get_grammar_entry
#		self.class.language::Grammar[get_grammar_entry]
	end
	def links
		wordclass.links
	end
	def word
		text_value.strip
	end
end

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
	def connectors
		list_connectors
	end
	def list_connectors
		equation.list_connectors			
	end
	def copy
		Linguistics.parse(text_value)
	end
	def links
		(list_connectors.collect { |con| con.links }).flatten
	end
	def delete_pairing!
		list_connectors.each {|con| con.delete_pairing! }
	end
	def sat?
		equation.sat?
	end
	def valid?
		equation.valid?
	end
	def disjuncts
		@disjuncts ||= equation.disjuncts.sort do |d1,d2| 
			d1.inject(0) { |r,e| r + e.cost } <=>  d2.inject(0) { |r,e| r + e.cost }
		end
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
		@links
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

	def pair(other,in_direction = :forward)
		in_direction = {:forward => "+", "+" => "+", :backward => '-', '-' => '-'}[in_direction]
		self.add_partner(other,in_direction)
		other.add_partner(self,(in_direction == '+') ? :backward : :forward)
	end

	def add_partner(other,in_direction = :forward)
		in_direction = {:forward => "+", "+" => "+", :backward => '-', '-' => '-'}[in_direction]
		(@pairings ||= {}).merge!( { other => in_direction } )
	end
	def ===(other)
		matchs?(other,:forward) or matchs?(other,:backward)
	end
	def matchs?(other,in_direction = :forward)
		in_direction = {:forward => "+", "+" => "+", :backward => '-', '-' => '-'}[in_direction]
		direction_match?(other,in_direction)  && upper_match?(other) && lower_match?(other)
	end
	def direction_match? other ,in_direction
		self.direction.text_value == in_direction	&& 
		!other.direction.nil?				&& 
		other.direction.text_value != in_direction  	
	end 
	def upper_match? other
		other.type.text_value == self.type.text_value
	end
	def lower_match? other
		mine = (arb.text_value + misc.text_value).each_char.collect { |c| c }
		theirs = (other.arb.text_value + other.misc.text_value).each_char.collect { |c| c }
		((mine.length < theirs.length) ? mine : theirs ).length.times.inject(true) do |r,c|
			r && (mine[c] == theirs[c] || mine[c] == '*' || theirs[c] == '*')  
		end
	end

	def pairings
		@pairings
	end

	def sat?
		!@pairings.nil? && (@pairings.length == 1 || !multiple.nil?) && 
		@pairings.all? { |k,v| self.matchs?(k,v) }
	end

	def valid?
		
		@pairings.nil? || (@pairings.length == 1 || !multiple.nil?) && 
		@pairings.all? { |k,v| self.matchs?(k,v) && self.wordclass != k.wordclass}
	end

	def has_pairings?
		!@pairings.nil?	
	end
	def disjuncts
		[[self]]
	end
###############################
end
###################### Treetop Parse Nodes ##############################
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
class Linguistics::Sentence < Treetop::Runtime::SyntaxNode
######################################
	public 
	##############################
	def words
		raise "Reached Linkage version must be overidden by including object"
	end
	def links
		@links
	end
	def link(index)
		@links[index]
	end	
	def disjunct_parse
		@parse_status ||= 0
		 disjunct_linkage_generate
	end
	def parse
		@parse_status ||= generate_linkage
	end
####################################
	private
	###########################
	def generate_linkage
		unless words.all? { |ele| ele.is_a?(Linguistics::WordClass) || ele.respond_to?(:grammar_equation) }
			raise "Array contains a non-wordclass object that doesn't respond to get_wordclass" 
		end
		link_list = create_linkages_table
		((words.length-1)..(link_list.length)).each do |i|
			link_list.combination(i) do |possible_link_array|
				wordclasses.each{|w| w.delete_pairing!}
				possible_link_array.each { |ph| ph[:forward].pair ph[:backward], :forward  }
				return set_linkages(possible_link_array) if wordclasses.all? { |w| w.sat? && w.valid? }
			end
		end
		return nil
	end
	# This function is called on a successful generation of linkages and sets up the sentence 
	def set_linkages(possible_link_array)
		words.length.times{ |i| words[i].wordclass = wordclasses[i] }
		@links = possible_link_array.collect do |lk| 
			link = Linguistics::Link.new(lk[:forward],lk[:backward], lk[:b_index] - lk[:f_index],lk[:f_index]) 
			lk[:backward].add_link(link) 
			lk[:forward].add_link(link) 
			link
		end
		true
	end
	def wordclasses
		@wordclasses ||= words.collect do |ele| 
			ele.is_a?(Linguistics::WordClass) ? ele.copy : ele.grammar_equation.copy
		end
	end

	def create_linkages_table()
		link_list = []
		# Generate All possible combintations
		wordclasses.length.times do |outer|
			wordclasses.length.times do |inner|
				next if outer >= inner
				oconn = wordclasses[outer].connectors
				iconn = wordclasses[inner].connectors
				pairings = oconn.product(iconn).find_all {|pair| pair[0].matchs? pair[1] , :forward }
				pairings.each do |pair| 
				link_list.push( {:forward => pair[0],:backward => pair[1],:f_index => outer,:b_index => inner } ) 
				end
			end
		end
		return link_list
	end
	def disjunct_linkage_generate
		dis_arr = 	wordclasses.collect { |wc| wc.disjuncts } # collection of disjunct arrays
		dis_arr = 	prune_disjuncts(dis_arr)		  # Prune disjuncts that can't exist
		# Use product to generate a list of all combinations of disjuncts that could work
		link_pool = 	dis_arr.inject([[]]) {|r,e| r.product(e).collect { |q| q.flatten } }
		binding.pry
		link_list = 	select_from_link_pool(link_pool)
		binding.pry

	end



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
			binding.pry
			next if ll.any? { |con| !con.sat? || !con.valid? } || 
				!_valid_lengths?(ll)
			return ll
		end
		return nil
	end
	
	def _valid_lengths?(ll,bl = nil, fl = nil)
		# if no bounds given generate default bounds
		bl = 0 if bl.nil?
		fl = wordclasses.length if fl.nil?  
		return true if (bl..fl).to_a.length <= 2 rescue binding.pry 
		# ^Recursive end case when the range of words being checking is empty 

		# Generate hash to allow determining the index of a connector's wordclass
		chsh = {}; lhsh = {}; wordclasses.length.times { |i| lhsh[wordclasses[i]] = i;chsh[i] = [] }	
		# Generate hash to allow determining the list of connectors in a wordclass (cant use list_connectors
		#	because some of those are invalid because they arent in the disjunct pool
		ll.each { |c| (chsh[lhsh[c.wordclass]] ||= []).push c }
		binding.pry
		# If any of the words have connectors that point out of the valid range the result if invalid
		return false if (bl...fl).to_a.any? { |i| chsh[i].any? { |con| 
					con.pairings.any? { |k,v| (v.to_s == '+') ? lhsh[k.wordclass] > fl : lhsh[k.wordclass] < bl } } }
		# Create a dividing point to seperate the words into those inside the longest link and outside the
		# longest link
		new_fl = chsh[bl].collect { |con| lhsh[con.pairings.keys.max { |p| lhsh[p.wordclass] }.wordclass] }.max 
		return	_valid_lengths?( ll , bl+1, new_fl ) && _valid_lengths?(ll,new_fl+1,fl) # test both subsets	
	end

	# Support pairing function for a link_pool v is the list of connectors (assumed of the same type
	def _pair_sub_array(v,id = '+')
		v.length.times do |i| 
			next if v[i].direction.text_value != id || (v[i].sat? && v[i].valid? && v[i].multiple.nil?)
			sd = 0; # Same Direction counter
			((i+1)...(v.length)).each do |ip|
				case 
					when v[ip].direction.text_value == id then sd = sd + 1
					when sd > 0 then sd = sd - 1
					when sd == 0 
						v[i].pair(v[ip], id) if v[i].matchs?(v[ip],id) && 
									(!v[ip].sat? || v[ip].multiple.nil?) 
						break if v[i].multiple.nil?
				end
			end 
		end
	end



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
##################### END Treetop Parse Nodes ########################
