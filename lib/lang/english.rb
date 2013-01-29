require 'pry'
require 'polyglot'
require 'treetop'
require 'linguistics'
class English < Language
	load_parser #TODO: Clean this up
	class Grammer < Language::Grammer
	end
	class Dictionary < Language::Dictionary
	end
	class Sentence  < Treetop::Runtime::SyntaxNode
		include Linguistics::Sequence
		def self.from_string(string)
			return English.parse(string)
		end	
		def words
			return @words unless @words.nil?
			ele = first
			(@words ||= [first.word]).push ele.word until (ele = ele.next).empty? 
			@words
		end
		def [](index)
			words[index]
		end
	end
	class Word < Treetop::Runtime::SyntaxNode
		def get_wordclass
			English::Grammer[English::Dictionary[text_value.strip].grammer]
		end
		def word
			text_value.strip
		end
	end

end

