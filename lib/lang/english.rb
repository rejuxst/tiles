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
	class Sentence  < Linguistics::Sentence
		def self.from_string(string)
			return English.parse(string)
		end	
		def words
			return @words unless @words.nil?
			ele = first
			(@words ||= [first.word]).push ele.word until (ele = ele.next).empty? 
			@words
		end
		def parse
			super
			(0...wordclasses.length).each {|i| words[1].wordclass = wordclasses[i] }
		end
		def [](index)
			words[index]
		end
		def nouns
			words.find_all { |w| English::Dictionary[w.word].grammer == "noun" }
		end
		def verbs
			words.find_all { |w| English::Dictionary[w.word].grammer == "verbs" } 
		end
		def subject
			(nouns.find_all { |w| w.is_subject? })[0]
		end
	end
	class Word < Language::Word 
		set_language English
		def is_subject?
			wordclass.connectors.any? { |con| !con.links.empty? && con.type.text_value == 'A' }
		end
	end

end

