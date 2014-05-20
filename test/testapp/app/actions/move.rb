require 'pry'
class Move < Action
	add_variable 'turn_cost', 1
	add_initialize_loop do |*args|
		add_reference_chain 'via',['path'],   :if_in_use => :overwrite
		add_reference_chain 'on',['path', 0], :if_in_use => :overwrite
	end
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
		m = Move.new({	'actor'  => source, 
				'path'   => [stile, stile[dir]],
				'target' => stile[dir]
			})
		m.enqueue_self(stile.db_parent.db_parent.eventhandler,source['turn'] || 0)
	end
	def preform_pre_callback
		# FIXME: MASSIVE VOLATION OF BEST PRACTICES NEED TO FIX EVENTHANDLING OF ACTIONCANCEL
		self['actor','turn'].set  self['actor','turn'] + self.class['turn_cost'] 
		raise ActionCancel, :invalid if self['actor'].db_parent == self['on'].db_parent
	end

	def calculate
		tile = self['target']
		tile = tile.db_parent until tile.is_a? Tile
		self['actor'].move_self_to_db tile		
	end
end
