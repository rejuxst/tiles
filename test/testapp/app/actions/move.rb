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
	def init
	end
	def preform_pre_callback
		raise ActionCancel, :invalid if @actor.db_parent == @target.db_parent
	end
	def calculate
		if !@target.is_a? Tile
			@target = @target.owner until @target.is_a? Tile
		end
		@actor.move_self_to_db @target
		
	end
end
