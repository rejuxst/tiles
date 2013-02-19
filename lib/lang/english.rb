require 'pry'
require 'polyglot'
require 'treetop'
require 'linguistics'
class English < Language
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
			return @parse_status if @parse_status
			wordclasses.length.times do |i| 
				words[i].wordclass = wordclasses[i] 
			end
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
		def adjectives
			(wordclass.connectors.find_all { |con| !con.links.empty? && con.type.text_value == 'A' }
			).collect { |con| con.links.collect {|lk| sentence[lk.index] } }.flatten
			.delete_if { |e| e.nil?}
		end
		def sentence
			parent.parent.parent rescue nil
		end
		def next(i = 1)
			i.times.inject(parent) { |wc,w| wc.next unless wc.nil? }.word rescue nil
		end

	end

end

