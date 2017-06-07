class Tiles::Application::EventHandler #NOTE: Should I make EventHandler a "Delegator" to a database so that I hide database interaction from user?
#######
# Event Handler is a disk_writable event priority queue that allows ordering events 
# and executing them. Events can be given priority values that are resolved as needed.
# Priority can be predetermined or calculated on the fly 
# Valid Time values:
#  :now	=> minimum time value accepted happens before any other time slot (is independent of definition of time)
#  :last	=> this is determined at enqueue time and is added to the end of the queue 
#  		(i.e if you :last an event and then :last another the first event will happen before the next)
#  time()	=> A valid time function
#  blk	=> An executable blk ???
#  now()	=> executed as the current queue head set. Priority within the set is resolved to include now()
#  after(blk) => a priority blk
#  before(blk) => a priority blk




  include Database::Data
  include Database::Base
  extend Database::Base
# TODO: NEED TO ADD FRAME_STACK CONSTRUCTOR AND TIMESPACE DB_DUMP() AND CONSTRUCTOR

###### Overridding Database Definitions #####
  def assign_key(obj)
  	super(obj)
  	case 
  		when obj.is_a?(Event) then 			"even:#{@max_key}"
  		when obj.is_a?(::Database::Reference) then 	"ref:#{@max_key}"
  	end
  end
#############################################



### var_readers
  attr_reader :timespace, :frame_stack
  def next_keyframe
  	timespace.create_entity(@frame_stack[0].key) unless @frame_stack.empty?
  end
  def next_frame
  	@frame_stack[0]
  end
  def last_frame
  	db_get 'last_frame'
  end
################





  def initialize(opts = {})
  	init_database	
  	@timespace = case opts[:timespace]
  		when Proc then Tiles::Factories::ComparableFactory.construct("#{self.class}:#{self.object_id}",&opts[:timespace])
  		when nil  then Tiles::Factories::ComparableFactory.blank_space
  		else opts[:timespace]
  	end
  	@frame_stack = []	
  	add_variable 	  'last_frame', nil
  	add_reference_set 'events', [] 
  	add_reference_set 'frames', []
  	add_reference_set 'listeners', [] 

  	if !opts[:start_at].nil?
  		st_at = timespace.create_entity(opts[:start_at])
  		_create_frame(st_at)
  	end

  end
  
  def execute_frame()
  	about_to_exec = next_keyframe
  	return if about_to_exec.nil?
  	_inform_listeners(next_keyframe)
  	if block_given?
  		@frame_stack.shift.events.each { |e| yield e }
  	else
  		@frame_stack.shift.events.each { |e| e.preform }
  	end
  	db_get('last_frame').set about_to_exec
  end

  def run (opts = {})
  	while !next_keyframe.nil? && next_keyframe <= opts[:until]  
  		execute_frame() 
  	end
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


  def register_listener(listener)
  	raise "Object Cant listen doesn't reaspond to inform" unless listener.respond_to? :inform
  	listeners.add listener
  end

  def empty?
  	self["events"].to_a.empty?
  end

  def inform(source_handler,frame_id)	
  	frames.each do |frame|
  		next if frame.key > frame_id || frame.key < last_frame.value
  		_inform_listeners(self,frame.key)
  		frame.events.each { |eve| eve.remove_self_from_db; enqueue(:event => eve, :at => frame_id) } 
  	end
  	last_frame.set frame_id
  end	


  private
  def _enqueue_to_frame(event,at)
  	raise "Invalid Key. Unable to enqueue at #{at} not defined in the given timespace." if !timespace.nil? && !timespace.entity?(at) 
  	at = timespace.create_entity(at)
  	add_to_db event
  	events.add event
  	(db_get(at) || _create_frame(at)).events.add event
  end
  def _create_frame(at)
  	frame = Frame.new
  	add_to_db(frame, timespace.create_entity(at).value)
  	db_get('frames').add frame 
  	for i in (0...@frame_stack.length).to_a	
  		@frame_stack.insert(i,frame) and break if at <= @frame_stack[i].key 
  	end unless @frame_stack.empty?
  	@frame_stack.push frame if @frame_stack.empty? || at > @frame_stack.last.key
  	db_get(at)
  end
  def _inform_listeners(frame_id)
  	listeners.each { |list| list.inform(self,frame_id) }
  end

end
class Frame 
  include Database::Data
  include Database::Base
  extend Database::Base
  def initialize()
  	init_database
  	add_reference_set 'events', []
  end
  def events
  	db_get('events')
  end
  def add(item,opts = {})
  	events.add(item,opts)
  end
end
