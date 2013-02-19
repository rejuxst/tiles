module LanguageCompiler
	def self.parse(string)
		(@@parser||= ::LanguageCompilerParser.new).parse string
	end
	def self.failure_reason
		@@parser.failure_reason
	end
	class Entry < Treetop::Runtime::SyntaxNode
		def is_comment?
			false
		end
	end
	class EntryName < Treetop::Runtime::SyntaxNode
	end
end
