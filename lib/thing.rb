require "action"
require "generic"
require "database"
class Thing
	include Generic::Base
	include Generic::Respond_To
	include Database
	# hash of all applicable state information with the key being an element on the definition database
	# and the value being either dynamically or statically defined
	attr_reader :ASCII
	def self.inherited(subclass)
		puts "A New Thing: #{subclass}"
	end	
	def initialize(args = {})
		@ASCII = '0'
		@ASCII = args[:ASCII] if !args[:ASCII].nil?
		self.init_database($thisgame);
		args[:controller].take_control(self) if !args[:controller].nil?
	end
end
