class Event < ::Tiles::BasicObject
	def init(opts = {})
		@blk = opts[:blk]
	end

	def preform
		@blk.call unless @blk.nil?
	end	

	def enqueue_self(eventhandler,at)
		eventhandler.enqueue(:event => self,:at => at)
	end
end
