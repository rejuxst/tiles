require 'tiles/lang/linguistics'
class Language
  def self.load_parser
  	Treetop.load File.join(File.dirname(__FILE__),"en/#{self.name.downcase}parser")
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
  	extend Database::Base
  	def self.add_class(wordclass,equation)
  		add_reference(wordclass,equation,:if_in_use => :overwrite) {|src,tar| ::Linguistics.parse(tar)}
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
  	self.class.language::Grammar[get_grammar_entry]
  end
  def links
  	wordclass.links
  end
  def word
  	text_value.strip
  end
end
