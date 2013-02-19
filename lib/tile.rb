require 'pry'
require "generic"
require 'database'
class Tile
	include Generic::Base
	include Generic::Responsive
	attr_reader :ASCII #this should only be read as the data should be stored in database
	def init(*args)
		unless args.nil?
			@ASCII = '0'
			@ASCII = args[0][:ASCII] if !args[0][:ASCII].nil?
			@things = []
			@owner = args[0][:owner] if !args[0][:owner].nil?
		end
	end
end
