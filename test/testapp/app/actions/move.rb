require 'pry'
class Move < Action
	def self.up(source)
		self.move_over_one(source,0,1)
	end
	def self.down(source)
		self.move_over_one(source,0,-1)
	end
	def self.left(source)
		self.move_over_one(source,-1,0)
	end
	def self.right(source)
		self.move_over_one(source,1,0)
	end
	def self.move_over_one(source,x,y)
		stile = source.db_parent
		return nil if stile.offset(x,y).nil?
		m = Move.new({:actor => source, :path => [stile, stile.offset(x,y)],:target=>stile.offset(x,y)})
		return m.preform
	end
	def preform_pre_callback
		raise ActionCancel, :invalid if from.db_parent == on.db_parent
	end
	def calculate
		tile= on
		tile = tile.db_parent until tile.is_a? Tile
		from.move_self_to_db tile
		
	end
end
