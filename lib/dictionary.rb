require 'linguistics'
class Language::Dictionary
# The dictionary module provides hooks to orgainze and store class data
# in an interface that allows modifiable indexing methods to streamline 
# the conceptual process of storing data. Dictionaries can be used to 
# organize class hierarchy store a complex array or provide a obfuscation
# API for file access.

# Dictionary creation API is integrated into Generic (EDIT: Is this for sure?)
	extend Database
	def self.add_word(word,wordclass) #TODO: Needs lots of improvements
		add_to_db Definition.new(word,wordclass), word
	end
	def self.[]=(key,value)
		add_word(key,value)
	end
	class Definition
		def initialize(word,wordclass)
			raise "Invalid Dictionay::Definition input" unless word.is_a? ::String and wordclass.is_a? ::String
			@word = word
			@wordclass = wordclass
		end
		def word
			@word
		end
		def grammer
			@wordclass
		end
	end
end
