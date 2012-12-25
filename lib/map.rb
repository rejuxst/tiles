require "generic"
require "active"
class Map
	include Generic::Base
	include Generic::Responsive
	include Active
	attr_reader :rows,:columns # number of rows and columns of tiles in the map
	attr_reader :parent, :maps # list of lower level maps
	attr_reader :tiles
	
	def initialize
		@parent = nil
		init
	end
	def init
		@rows = 	20
		@columns = 	20
		@tiles = Array.new(@rows) do |e|
			e = Array.new(@columns) {Tile.new(:ASCII => ".",:owner => self)}
		end
	end
	# Tile access and manipulation functions 
	def tile(r,c)
		return nil if (r > @rows || r < 0) || (c > @columns || c < 0)
		if block_given?
			@tiles[r][c] = yield @tiles[r][c] 
		else
			return @tiles[r][c]
		end
	end
	
	def tile=(r,c,input)
		@tiles[r][c] = input 
	end	
	
	def find_tile(args={},&blk)
		sol = {:tile => nil, :r => 0, :c => 0}
		@rows.times do |r|
			@columns.times do |c|
				if yield tile(r,c)
					sol[:tile] = tile(r,c)
					sol[:r]	= r
					sol[:c] = c
					return sol
				end
			end
		end
		return sol
	end
	#########
end
