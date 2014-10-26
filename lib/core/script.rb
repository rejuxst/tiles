require 'polyglot'
require 'treetop'

module Scriptable
# The scriptable module provides core scripting functionality to parse interprete and preform
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

  	def is_blockname_valid?(name)
  		name.to_s == 'begin'
  	end
  	def execute_element(name,params = nil,inputs = nil)
  	end
  	def add_blockname(name)
  	end
  
  class InternalScript < Treetop::Runtime::SyntaxNode
  	def list
  		entries.elements.collect {|e| e.ent }
  	end
  end

  class Element < Treetop::Runtime::SyntaxNode
  end

  class Block < Treetop::Runtime::SyntaxNode
  	def name
  		begin_element.name
  	end
  end

  def self.block_names(name = nil)
  	return @block_names if name.nil?
  	@block_names ||= {}
  	@block_names[name]
  end
  def self.add_block_name(name)
  	@block_name ||= {}
  	@block_name[name] = true
  end
  def self.on_load_callback(name)
  end
  def import(package)
  end
  def self.finished_resolving_element(name)
  end

end

require 'grammars/scriptable'
class Script < ScriptableParser
  def initialize(string)
  	super()
  	@script = parse string
  end
end
