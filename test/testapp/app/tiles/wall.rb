class Wall < Tile
	add_response :move, :via, :cancel
	add_response :move, :target, :cancel

	def init(args)
		@ASCII = 'X'
	end
end
class Door < Wall
	def init(args)
		@ASCII = 'D'
	end
end
