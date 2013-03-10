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

	def initialize
		init_database
		add_reference_collection "repeating",  		[]
		add_reference_collection "periodically_do",	[]
		add_reference_collection "events"	,	[]
		add_reference_collection "handlers"	,	[]
		create_timeframe("now")
	end
	def initialize
		@space = []
		@eventkey = 0 
	end
	def enqueue(opts = {})
		# :interval 	=> 	interval: 	last_occurance + interval = enqueue_event(event)
		# :at 		=>	time  	:	enqueue_event(event,time)
		# :before/:after/.... => blk... :	More verbose methodes of enqueueing
		# :in_order	=>	blk	:	priority coding for set order
		# :reference_as => 	name	:	how to dereference the event from the queue 
		
	end
	# dequeue a subset of the event handlers for processing
	def run(opts = {},&blk)
		# :time_interval => interval
		# :event	 => EventClass
		# :empty	 => process all outstanding events (empty is defined as all events  
	end
	def queue
	end
	# Allows Scoping and generation of event handlers 
	#	(primarly for implimenting reliable scoped/temporary 
	#		event handlers and propagating them upstream)
	def register(opts ={})
		# :check_at => time (:now,:always,:last) 
		# :interval => interval
		# :reference_as =>	name
		# :listener 	=> A party that wants to be aware of all executed events in the space
		# :event_handler => A sub event handler that wants to feed into the execution loop of this event handler
	end
	
	# Periodically preform the block based on options. Intended to initiate actions
	# in ways that semantically dont make sense as an event or action.
	#  i.e allowing all players to take a turn, there may not be a specific "event"
	#	that would cause them to take a turn so there needs to be a way to make it happen.
	def periodically(opts = {},&blk)
		# :interval => Time
		# :do	    => blk or blk_like object event
		# :when     => true/false block, Time, Event
		# event_class  => event_init hash	
	end
	private
	def _run_now
		@db.events.each {|e| e.preform }
		@db.update_nowframe
	end
	def _proc_isa_time?
		Proc.new { |ops| ops.is_a? Time }
	end
	def _register_eventhandler
	end
	def _register_listener
	end
end
class Tiles::Application::EventHandler_Delegated
	include Database::Data
	include Database::Base
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
		add_variable 'timespace', opts[:time_space]
		add_variable 'last_frame'   , 		nil
		add_reference_collection 'events', 		[] 
		add_reference_collection 'frames', [
				add_reference_set( opts[:start_at] || 0, [] )
				]
		add_variable 'next_keyframe', db_get.resolve().to_a.min{ |x,y| x <=> y}.value		
		#opts[:start_at] || 0
	end
	def execute_frame()
		if block_given?
			yield self[db_get("next_keyframe")]
		else
			self[db_get("next_keyframe")].preform
		end
		db_get('last_frame').set db_get('next_keyframe').value
		
	end

	def move_keyframe(key)
		db_get('next_keyframe').set key
	end
	def enqueue(opts = {})
		event = opts[:event]
		at = opts[:at] || event.time
		raise ArgumentException if event.nil? || at.nil?
		case  
			when !(at_k = db_get(opts[:at])).nil? 			then _enqueue_to_frame(event,at_k)
			when !timespace.nil? && timespace.entity?(opts[:at]) 	then _create_frame(opts[:at]) 
		end 
	rescue ArgumentException => e
		raise e, "Didn't provide sufficient and correct arguments to enqueue call.
			  Also possible that the provided event didn't have a time function => #{opts}".delete("\n\t")
	end
### var_readers
	def next_keyframe
		db_get 'next_keyframe'
	end
	def last_frame
		db_get 'last_frame'
	end
################


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
			create_timeframe "now",   		:if_in_use => :destroy_entry
		else	
			add_reference_chain "now", now[:next],  :if_in_use => :destroy_entry
		end	
	end
	private
	def _enqueue_to_frame(event,at)
		add_to_db event
		at.add event.key
	end
	def _create_frame(at)
		db_get('frames').add add_reference_set timespace.to_e(at,self), []
	end
	
end
## ???? Should this exist ???? ###
class Tiles::Application::SetHandler
	## ?????? Maybe this should be more like Tiles::ScopedObjectSpace ???????
end
