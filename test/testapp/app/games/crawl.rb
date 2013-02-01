class Crawl < Game
	def init
		 add_reference "map", Dungeon.new, :add_then_reference => true
	end
	def start
	end
end
