require 'linguistics'
class Dictionary
# The dictionary module provides hooks to orgainze and store class data
# in an interface that allows modifiable indexing methods to streamline 
# the conceptual process of storing data. Dictionaries can be used to 
# organize class hierarchy store a complex array or provide a obfuscation
# API for file access.

# Dictionary creation API is integrated into Generic (EDIT: Is this for sure?)

# 
attr_reader :word_classes
def self.add_word_class(word_class)
	@word_classes << word_class
end
class Basic
	attr_reader :entries

		

end
class Master < Basic

end
class Local < Basic

end
end
