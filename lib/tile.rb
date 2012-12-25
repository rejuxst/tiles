require "generic"
require 'database'
class Tile
	include Generic::Base
	include Generic::Responsive
	attr_reader :ASCII #this should only be read as the data should be stored in database
	def initialize(*args)
		unless args.nil?
			@ASCII = '0'
			@ASCII = args[0][:ASCII] if !args[0][:ASCII].nil?
			@things = []
			@owner = args[0][:owner] if !args[0][:owner].nil?
		end
	rescue
	ensure
		init
	end
	def init
	end
	def offset(x,y)
		if db_parent.class <= Map
			sol = db_parent.find_tile {|t| t == self}
			return nil if sol[:tile].nil?
			return db_parent.tile(sol[:r]+y,sol[:c]-x)
		else
			raise "offset doesn't work on tiles not owned by a map"
		end
	end
end
