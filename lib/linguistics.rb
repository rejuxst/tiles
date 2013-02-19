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
	class Grammer
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
	def get_grammer_entry
		get_dictionary_entry.grammer
	end
	def grammer_equation
		self.class.language::Grammer[get_grammer_entry]
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
		equation.disjuncts
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
	def delete_pairing!
		@pairings = nil
	end

	def pair(other,in_direction = :forward)
		self.add_partner(other,in_direction)
		other.add_partner(self,(in_direction == :forward) ? :backward : :forward)
	end

	def add_partner(other,in_direction = :forward)
		(@pairings ||= {}).merge!( { other => in_direction } )
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
		!@pairings.nil? && (@pairings.length == 1 || !multiple.nil?) && @pairings.all? { |k,v| self.matchs?(k,v) }
	end

	def valid?
		@pairings.nil? || (@pairings.length == 1 || !multiple.nil?) && @pairings.all? { |k,v| self.matchs?(k,v) }
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
		start.disjuncts + other_terms.elements.collect { |e| e.term.disjuncts } 
	end
end
class Linguistics::OperandsNode < Linguistics::DisjunctNode
	def sat?
		start.valid? && 	# All valid
		other_terms.elements.all? { |ele|  ele.empty? || ele.term.valid? }  && 
		( start.sat? || 	# Any term satisfied
			other_terms.elements.any? { |ele|  !ele.empty? && ele.term.sat? && ele.term.valid? }
			)
		#val && (start.sat? || an) # Including start validity
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
	def parse
		@parse_status ||= generate_linkage
	end
####################################
	private
	###########################
	def generate_linkage
		unless words.all? { |ele| ele.is_a?(Linguistics::WordClass) || ele.respond_to?(:grammer_equation) }
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
		@wordclasses ||= words.collect {|ele| ele.is_a?(Linguistics::WordClass) ? ele.copy : ele.grammer_equation.copy}
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
end
##################### END Treetop Parse Nodes ########################
