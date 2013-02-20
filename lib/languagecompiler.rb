module LanguageCompiler
	def self.parse(string)
		(@@parser||= ::LanguageCompilerParser.new).parse string
	end
	def self.failure_reason
		@@parser.failure_reason
	end
	def self.generate_instance_dictionary(lang,dict)
		dict.entries.each do |ent|
			lang::Dictionary.add_word(ent.name.text_value, ent.equation.text_value)
		end
	end
	class Entry < Treetop::Runtime::SyntaxNode
		def is_comment?
			false
		end
	end
	class EntryName < Treetop::Runtime::SyntaxNode
	end
end
