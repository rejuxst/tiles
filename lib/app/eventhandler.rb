class Tiles::Application::EventHandler #NOTE: Should I make EventHandler a "Delegator" to a database so that I hide database interaction from user?
#######
# Event Handler is a disk_writable event priority queue that allows ordering events 
# and executing them. Events can be given priority values that are resolved as needed.
# Priority can be predetermined or calculated on the fly 
# Valid Time values:
#	:now	=> minimum time value accepted happens before any other time slot (is independent of definition of time)
#	:last	=> this is determined at enqueue time and is added to the end of the queue 
#			(i.e if you :last an event and then :last another the first event will happen before the next)
#	time()	=> A valid time function
#	blk	=> An executable blk ???
#	now()	=> executed as the current queue head set. Priority within the set is resolved to include now()
#	after(blk) => a priority blk
#	before(blk) => a priority blk
	include Database::Data
	include Database::Base
	extend Database::Base
	attr_reader :timespace
###### Overridding Database Definitions #####
	def assign_key(obj)
		super(obj)
		case 
			when obj.is_a?(Event) then 			"even:#{@max_key}"
			when obj.is_a?(::Database::Reference) then 	"ref:#{@max_key}"
		end
	end
#############################################
	def initialize(opts = {})
		init_database	
		@timespace = case opts[:timespace]
			when Proc then Tiles::Factories::ComparableFactory.construct("#{self.class}:#{self.object_id}",&opts[:timespace])
			else opts[:timespace]
		end
		add_variable 'last_frame'   , 		nil
		add_reference_collection 'events', 		[] 
		st_at = timespace.create_entity(opts[:start_at] || 0)
		add_reference_set( st_at, [] )
		add_reference_collection 'frames', [ st_at ]
		add_variable 'next_keyframe', st_at 
		add_reference_set( 'listeners', [] )

	end

	def db_get(key)
		super(key) || super(timespace.create_entity(key)) 
	rescue Exception => e 
		unless timespace.nil?
			super(timespace.create_entity(key)) 
		else 
			raise e
		end
	end
	
	def execute_frame()
		inform_listeners(next_keyframe)
		if block_given?
			self[db_get("next_keyframe").value].each { |e| yield e }
		else
			self[db_get("next_keyframe").value].each { |e| e.preform }
		end
		db_get('last_frame').set db_get('next_keyframe').value
		db_get('next_keyframe').set db_get('frames').reject { |f| f.key <= last_frame.value }.min_by {|f| f.key }
	end

	def run (opts = {})
		while !next_keyframe.nil? && next_keyframe.value >= opts[:until]  
			execute_frame() 
		end
	end

	def move_keyframe(key)
		db_get('next_keyframe').set key
	end

	def enqueue(opts = {})
		event = opts[:event]
		at = opts[:at] || event.time
		raise ::ArgumentError if event.nil? || at.nil?
		_enqueue_to_frame(event,at)
	rescue ::ArgumentError => e
		raise e, "Didn't provide sufficient and correct arguments to enqueue call.
			  Also possible that the provided event didn't have a time function => #{opts}".delete("\n\t"), e.backtrace
	end



### var_readers
	def next_keyframe
		db_get 'next_keyframe'
	end
	def last_frame
		db_get 'last_frame'
	end
################

	def register_listener(listener)
		raise "Object Cant listen doesn't reaspond to inform" unless listener.respond_to? :inform
		listeners.add listener
	end



	def create_timeframe(id,opts = {})
		add_reference_collection id, [],opts
		self[id].blank_set(:events)
		self[id]
	end

	def empty?
		self["events"].to_a.empty?
	end

	def update_nowframe
		now[:events].each { |e| e.destroy_self if e.respond_to? :destroy_self}
		if now[:next].is_a?( ::Database::Reference ) 
			add_to_db now[:next],"now"
		elsif now[:next].is_a?( NilClass ) 	
		_inform_listeners(self,frame_id)
			create_timeframe "now",   		:if_in_use => :destroy_entry
		else	
			add_reference_chain "now", now[:next],  :if_in_use => :destroy_entry
		end	
	end

	def inform(source_handler,frame_id)	
		frames.each do |frame|
			next if frame.key > frame_id || frame.key < last_frame.value
			_inform_listeners(self,frame.key)
			frame.each { |eve| eve.remove_self_from_db; enqueue(:event => eve, :at => frame_id) } 
		end
		last_frame.set frame_id
	end	


	private
	def _enqueue_to_frame(event,at)
		raise "Invalid Key. Unable to enqueue at #{at} not defined in the given timespace." if !timespace.nil? && !timespace.entity?(at) 
		add_to_db event
		(db_get(at) || _create_frame(at)).add event
	end
	def _create_frame(at)
		db_get('frames').add add_reference_set timespace.create_entity(at), []
		move_keyframe(timespace.create_entity(at)) if next_keyframe.nil? || (timespace.create_entity(at) < next_keyframe.value)
		binding.pry
		db_get(at)
	end
	def _inform_listeners(frame_id)
		listeners.each { |list| list.inform(self,frame_id) }
	end
end
## ???? Should this exist ???? ###
class Tiles::Application::SetHandler
	## ?????? Maybe this should be more like Tiles::ScopedObjectSpace ???????
end
