require 'pry'
class Test_Linguistics < Tiles_Test
	def add_to_dict(word,wordclass)
		$dictionary = {} if $dictionary.nil?
		$dictionary[word] = wordclass
	end
	def load_test_word_lib
		add_to_dict("a",$indefinite_article)
		add_to_dict("dog",$noun)
		add_to_dict("ran",$verb)
		add_to_dict("fast",$adverb)
		add_to_dict("the",$definite_article)
	rescue
		binding.pry	
	end
	def load_test_word_classes
		$word_class_list = Hash.new()
		$word_class_list[:definite_article] 	= Linguistics::WordClass.new(:definite_article, "ArticleNoun+")
		$word_class_list[:indefinite_article] 	= Linguistics::WordClass.new(:indefinite_article, "ArticleNoun+")
		$word_class_list[:noun]			= Linguistics::WordClass.new(:noun, "{ArticleNoun-} and NounVerb+")
		$word_class_list[:verb]	 	    	= Linguistics::WordClass.new(:verb, "{AdverbVerb+} and NounVerb-")
		$word_class_list[:adverb]	     	= Linguistics::WordClass.new(:adverb,"AdverbVerb-")
		$word_class_list.each {|key,value| eval("$#{key.to_s} = value"); }
	rescue
		puts "Errored out on load_test_word_lib refer to $word_class_list"
		binding.pry
	end
	def load_test_sentences
		begin
		$sentences = []
		$sentences.push Linguistics::Sentence.from_string("A dog ran.",$dictionary)
		$sentences.push Linguistics::Sentence.from_string("The dog ran fast.",$dictionary)
		$sentences.each do |local|
			puts	"Sentence(\"#{local.to_string()}\") \n\tLink Table: #{local.create_linkages_table}"
		end
		rescue
			binding.pry
		end
		$sentences.each { |sen| sen.resolve rescue binding.pry }
	end
	def sentence_from_string(string)
		arr = string.split(/[\., ]/).collect { |s| s.downcase }
		output = Linguistics::Sentence.new
		arr.each {|word| output.add_word Linguistics::Word.new($dictionary[word],word) }
		return output
	rescue 
		binding.pry
	end
	def test_load_bare_linguisitics
		load_test_word_classes # Load the Word Classes (Word Class Test Bench)
		load_test_word_lib     # Load the Library    (Word / Connector Test Bench)
		load_test_sentences    # Load Test Sentences (Sentence Parsing Test Bench)	
	rescue
		assert(false,"Failed Linguistics test")
	end
end
