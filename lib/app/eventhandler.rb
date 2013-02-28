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
	include Database
	def initialize
		init_database
	end
	def enqueue_event(event,opts = {})
		# :interval 	=> 	interval: 	last_occurance + interval = enqueue_event(event)
		# :at 		=>	time  	:	enqueue_event(event,time)
		# :before/:after/.... => blk... :	More verbose methodes of enqueueing
		# :in_order	=>	blk	:	priority coding for set order
		# :reference_as => 	name	:	how to dereference the event from the queue 	
		add_to_db event, :append => true 
	end
	# dequeue a subset of the event handlers for processing
	def dequeue(count,&blk)
	end

	# Allows Scoping and generation of event handlers 
	#	(primarly for implamenting reliable scoped/temporary 
	#		event handlers and propagating them upstream)
	def register_event_handler(handler,opts ={})
		# :check_at => time (:now,:always,:last) 
		# :interval => interval
		# :reference_as =>	name
		# 
	end

	#Periodically do a set of actions or generate event
	def periodically_do(opts = {},&blk)
		
	end
end
