require 'pry'
require 'polyglot'
require 'treetop'
require 'linguistics'
class English < Language
	load_parser
	class Sentence  < Treetop::Runtime::SyntaxNode
		def self.from_string(string)
			
		end	
		def words
			ele = first
			(arr ||= [first.word]).push ele.word until (ele = ele.next).empty? 
			arr
		end
	end
	class Word	< Treetop::Runtime::SyntaxNode

	end

end

