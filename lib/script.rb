module Scriptable
# The scripbtable module provides core scripting functionality to parse interprete and preform
# tiles scripts. Tiles scripts are designed to use a limited vocabuary that will allow developers
# to write software in a language that physically resembles english and operates in a similar manner.
# To this end the idiom of the Tiles engine should and will encourage developement through a
# certain methodology
# example functional line: Attack target with weapon if weapon is melee otherwise Shoot.
# example functional line: I repond to an Attack with a Defence (conjugation of Defend).
# example descriptive line: A Melee is a variation of an Attack.
# Syntax:
# All script lines can be delimited by a period(.), semicolon(;) or newline character('\n')
# Lines can be extend past a newline of the line includes an ellipsis(...)
# Scripts are started with def Name_of_Script(ended with end) when identifiying a script external to the reading unit
#  the Name_of_Script will be obfuscated to Name_of_File-Name_of_Script (as a result no script name can start or end with a dash(-)
# Outside of a script Name_of_script.function can be used to modify the operational mode of the script. anything not inside a def end block
#  wll be read as ruby code but limited to operation via or on the Script instance.
	def self.read()
	end
# repond|to|with|as|because|_if|_and|perform|_do|_end|
# close|start|_read|action|reponse|it|their|my|all|us|
# we|is|a|many|owned|by|player|game|the|

# Source Dictionary
# Master Dictionary

# Sentence Context- ??List Context??
# Script Context -
# Word Context-
# Owner Context - this is recursive up the ownership stack
attr_reader :script_sentence
attr_reader :script_db
	def interpret_script(string)
		if string.class != String
			begin
			string = string.to_s 
			rescue 
			raise "Passed a Non-String to a #{self.class.to_s}" unless(string.class <= String)
			end
		end
		@script_sentence = Scriptable::Sentence.new(self)
		string.for_each do |c| 
			if (@script_sentence.send_char(c)) == :complete
				@script_sentence.next= Scriptable::Sentence.new(self,@script_sentence)
				@script_sentence = @script_sentence.next
			end
		end

	end

class Sentence
	attr_reader :state		# Sentence State
	attr_reader :next, :previous 	# Before/After Sentences
	attr_reader :children, :parent  # Up and Down motion
	attr_reader :context  		# Context is the parent
	attr_reader :delimiter		# The Delimiter that ended the context
	def initialize(context,previous = nil,parent = nil)
		#raise "Context is not Scriptable #{context}"unless context.include? Scriptable
		@context  = context
		@previous = previous
		@parent   = parent
		@children = []
		@children << Word.new(@context,@previous,self)
		@state    = :new
	end
	def send_char(char)
		return :leading_whitespace if @state == :new && /\ \n/.match(char).nil?
		@state = :in_progress 
		if  @children.last.send_char(char) == :complete
			@children << Word.new(@context,@current,self)
		end
		if /[\.;\!\:]/.match(char) # A sentence can be ended by a semi-colon,colon,period
			@state = :complete 
			@delimiter = char	
		end
		return @state
	rescue
		raise	
	end
	def print
	end
	def resolve
	end
end
class Word
	attr_accessor 	:next   	# Previous Word
	attr_reader	:word		# Current Word String
	attr_reader 	:previous	# After Word
	attr_reader	:parent		# Parent Context
	attr_reader 	:context  	# Context is the parent
	attr_reader	:delimiter	# Completion Delimiter
	def initialize(context,previous = nil,parent = nil)
		@context  = context
		@previous = previous
		@parent   = parent
		@state    = :new
		@string   = ''
	end
        def send_char(char)
                return :leading_whitespace if @state == :new && /\ \n/.match(char).nil?
                @state = :in_progress 
                if /[\!,;:\.\ ]/.match(char)
		# A Word can be completed by a:
		# :punctuation: or :whitespace:
                        @state = :complete 
                        @delimiter = char
			resolve
			return @state
                end
		@string << char
                return @state
        end

	def print
		return @string
	end
	def resolve
		interpretation = @context.dictionary_lookup(@string)
		# Resolve interpretation into context
	end
end

end
class Script
	include Scriptable
end
