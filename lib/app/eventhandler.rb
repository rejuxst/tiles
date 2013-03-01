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
#	include Database
	def initialize
		@db = Tiles::Application::EventHandler_Delegated.new #init_database
	end
	def enqueue_event(event,opts = {})
		# :interval 	=> 	interval: 	last_occurance + interval = enqueue_event(event)
		# :at 		=>	time  	:	enqueue_event(event,time)
		# :before/:after/.... => blk... :	More verbose methodes of enqueueing
		# :in_order	=>	blk	:	priority coding for set order
		# :reference_as => 	name	:	how to dereference the event from the queue 
		@db.add_to_db event
		@db.events.add event
		case opts[:at]
			when :now then @db.now[:events].add event
			
		end
	end
	# dequeue a subset of the event handlers for processing
	def run(opts = {},&blk)
		# :time_interval => interval
		# :event	 => EventClass
		# :empty	 => process all outstanding events (empty is defined as all events  
		case opts[:until]
			when :now,:next_frame 	then _run_now
			when :empty 		then _run_now until @db.events.to_a.empty?
		end
	end
	def queue
		@db.events
	end	
	# Allows Scoping and generation of event handlers 
	#	(primarly for implimenting reliable scoped/temporary 
	#		event handlers and propagating them upstream)
	def register_event_handler(handler,opts ={})
		# :check_at => time (:now,:always,:last) 
		# :interval => interval
		# :reference_as =>	name
		# 
	end
	# Periodically preform the block based on options. Intended to initiate actions
	# in ways that semantically dont make sense as an event or action.
	#  i.e allowing all players to take a turn, there may not be a specific "event"
	#	that would cause them to take a turn so there needs to be a way to make it happen.
	def periodically(opts = {},&blk)
		
	end
	private
	def _run_now
		@db.events.each {|e| e.preform }
		@db.update_nowframe
	end
end
class Tiles::Application::EventHandler_Delegated
	include Database
	def initialize
		init_database
		add_reference_collection "repeating",  		[]
		add_reference_collection "periodically_do",	[]
		add_reference_collection "events"	,	[]
		add_reference_collection "handlers"	,	[]
		create_timeframe("now")
	end
	def create_timeframe(id,opts = {})
		add_reference_collection id, [],opts
		self[id].blank_set(:events)
		self[id]
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
end
