require 'pry'
def non_interactive?
	return false
end
def require_from_source
	$LOAD_PATH << File.absolute_path(File.join(File.dirname(__FILE__),'/../../lib/'))
	core = File.join(File.dirname(__FILE__),"..","..","lib")
	puts "$LOAD_PATH LIST:"
	puts $LOAD_PATH
	Dir.open(core) do |ent|
		ent.entries.each do |f|
		unless File.directory?(File.join(core,f)) || !(f.match(/\.gitignore/).nil?) || !(f.match(/\.swp/).nil?)
			succ = gem_original_require File.expand_path File.join(ent.to_path,f.partition('.')[0])
			puts "Requiring lib file: #{File.join(f.partition('.')[0])} => #{succ}"
		end
		end
	end
rescue
        binding.pry
end
def add_to_dict(word,wordclass)
	$dictionary = {} if $dictionary.nil?
	$dictionary[word] = Linguistics::Word.new(wordclass,word)
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
	$sentences = []
	$sentences.push sentence_from_string("A dog ran.")
	$sentences.push sentence_from_string("The dog ran fast.")
	$sentences.each do |local|
		puts	"Sentence Link Table: #{local.create_linkages_table}"
	end
	$sentences.each { |sen| sen.resolve rescue binding.pry }
end
def sentence_from_string(string)
	arr = string.split(/[\., ]/).collect { |s| s.downcase }
	output = Linguistics::Sentence.new
	arr.each {|word| output.add_word $dictionary[word] }
	return output
rescue 
	binding.pry
end
begin
	require_from_source    # Load the Tiles Core (Syntax Test Bench)
	load_test_word_classes # Load the Word Classes (Word Class Test Bench)
	load_test_word_lib     # Load the Library    (Word / Connector Test Bench)
	load_test_sentences    # Load Test Sentences (Sentence Parsing Test Bench)
	unless non_interactive? # Alias global to local
		binding.pry
	end
rescue
	binding.pry
end
