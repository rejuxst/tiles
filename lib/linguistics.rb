require 'database'
require 'treetop'
require 'pry'
class Language
	def self.new_wordclass(wordclass,equation)
		include Database if not include? Database
		add_to_db equation , wordclass
	end
	def self.add_word(word,wordclass)
		include Database if not include? Database
		add_to_db wordclass , word
	end
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
end

module Linguistics
###### Setup

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
###########################
##### Linguistics Classes
	class WordClass < Treetop::Runtime::SyntaxNode
		def connectors
			list_connectors
		end
		def list_connectors
			equation.list_connectors			
		end
	end
	class Connector < Treetop::Runtime::SyntaxNode
		def list_connectors
			[self]
		end
	end
###################### Treetop Parse Nodes ##############################
	class DisjunctNode < Treetop::Runtime::SyntaxNode
		def list_connectors
			case
			when  	other_terms.empty? then [] 
			else 	other_terms.elements.collect {|t| t.term.list_connectors}
			end.flatten + start.list_connectors
		end
	end
	class OperandsNode < DisjunctNode
	end
	class OptionalNode < Treetop::Runtime::SyntaxNode
		def list_connectors
			or_rule.list_connectors
		end
	end
	class ParenNode < Treetop::Runtime::SyntaxNode
		def list_connectors
			content.nil? ? [] : content.list_connectors
		end
	end
##################### END Treetop Parse Nodes ########################
end #END Linguistics

