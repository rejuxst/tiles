module LanguageCompiler
	def self.parse(string)
		(@@parser||= ::LanguageCompilerParser.new).parse string
	end
	def self.failure_reason
		@@parser.failure_reason
	end
	def self.generate_instance_dictionary(lang,dict)
		dict.entries.each do |ent|
			ent.names.each do |name|	
			lang::Dictionary.add_word(name.text_value, name.text_value)
			lang::Grammar[name.text_value]= ent.equation.text_value
			end 
		end
	end
	class Entry < Treetop::Runtime::SyntaxNode
		def is_comment?
			false
		end
		def names
			[nm] + nms.elements.collect { |n| n.nm }
		end
	end
	class EntryName < Treetop::Runtime::SyntaxNode
		def is_instance?
			type.text_value == ''
		end
		def is_global?
			type.text_value == '$'
		end
		def is_class?
			type.text_value == '@'
		end
		def name
			nm.text_value
		end
	end
	class Regex < Treetop::Runtime::SyntaxNode
		def regex
			::Regex.new text_value
		end
	end
end
