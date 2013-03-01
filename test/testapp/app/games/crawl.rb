class Crawl < Game
	def init
		 add_reference "map", Dungeon.new, 
			:add_then_reference => :destroy_entry,:if_in_use => :destroy_entry
	end
	def start
	end
end
