require 'pry'
class Move < Action
	def self.up(source)
		self.move_over_one(source,"up")
	end
	def self.down(source)
		self.move_over_one(source,"down")
	end
	def self.left(source)
		self.move_over_one(source,"left")
	end
	def self.right(source)
		self.move_over_one(source,"right")
	end
	def self.move_over_one(source,dir)
		stile = source.db_parent
		return nil if stile[dir].nil?
		m = Move.new({	:actor  => source, 
				:path   => [stile, stile[dir]],
				:target => stile[dir]
			})
		return m.preform
	end
	def preform_pre_callback
		raise ActionCancel, :invalid if from.db_parent == on.db_parent
	end
	def calculate
		tile = on
		tile = tile.db_parent until tile.is_a? Tile
		from.move_self_to_db tile		
	end
end
