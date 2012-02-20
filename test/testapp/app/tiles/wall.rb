class Wall < Tile
	class_responds_to :Move, :via, :cancel
	def init
		@ASCII = 'X'
	end
end
class Door < Wall
	def init
		@ASCII = 'D'
	end
end