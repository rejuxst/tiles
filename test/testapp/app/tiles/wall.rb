class Wall < Tile
	add_response :move, :via, :cancel
	add_response :move, :target, :cancel

	def init
		@ASCII = 'X'
	end
end
class Door < Wall
	def init
		@ASCII = 'D'
	end
end
