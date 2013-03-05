class Event < ::Tiles::BasicObject
	def init(opts = {})
		@blk = opts[:blk]
	end
	def preform
		@blk.call unless @blk.nil?
	end	
	
end
