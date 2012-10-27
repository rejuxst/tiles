require "generic"
require 'database'
class Tile
	include Generic::Base
	include Generic::Respond_To
	include Database
	class_responds_to :Move, :via, :none
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
		if owner.class <= Map
			sol = owner.find_tile {|t| t == self}
			return nil if sol[:tile].nil?
			return owner.tile(sol[:r]+y,sol[:c]-x)
		else
			raise "offset doesn't work on tiles not owned by a map"
		end
	end
end
