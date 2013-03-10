#Empty Namespace
class Tiles::Factories < Tiles::ClassSpace
	
end
# Functional Space for generation time classes
class Tiles::Factories::TimeFactory < BasicObject
	def self.generate_timespace(opts = {})
		# "%s %w %q" => [:days, :weeks, :years] (Definition of to String from string format)
		# Symbol => String/Proc   (define the function Symbol that casts the time value using String as a Equation)
		#			ex. :today => { |raw| %w[Monday Tuesday Wendsday Thursday ....][raw % 7] } (block)
		#			ex. :days  => :raw (default reference)
		#			ex. :months => "raw % 30" (Equation)
		# :valid_units	=> Array  (of the listed Symbols that themselves are valid units)
		#				This allows for "dimensional analysis" i.e "years = date - month - day"
		# :default_value => value	(Time.new without passed value defaults to this value)
	end
end
class Tiles::Factories::ComparableFactory
# Ex.
# a = ((((Tiles::Factories::ComparableFactory.blank_factory(:name =>'::LingComp') < 
#		:before < :now  < :after).move_to(:now) == :present) < :future ) == :after).generate
# ^ Generates a Comparision Space with :fore being less than :now and :present which are less than :after 
	@@space_list ||= {}
	private_class_method :new
##### Class Methods
	def self.blank_factory(opts ={})
		new(opts)
	end
	def self.construct(name,opts = {},&blk)
		a =  new(name) if block_given? || !blk.nil?	
		(block_given?) ? yield(a) : blk.call(a)
		(!opts[:generate_after].nil? && opts[:generate_after] == false)? a : a.generate
	end
	def self.[](name)
		@@space_list[name.to_s]
	end
	private
	def self.register_space(name,space,make_global = false)
		#mod = name.split('::')[0..-2]
		#	.inject(self) { |cl,sp| (sp.empty?) ? cl : cl.const_get(sp) } 
		#	.const_set name.split('::')[-1] , am
		@@space_list[name.to_s] = space
		#mod.const_set 'ComparisonSpace', space
	end
	public
	attr_reader :space,:pobj,:plvl
	def initialize(name)
		@name = name.to_s
		@space = [_new_space]
		@pobj = nil
		@plvl = 0
		# Hash Method
		@spacehash = {}
		@instances = []
		@sets	   = []
		
	end
	def [](*args)
		Worker.new(self,args)	
	end
	def generate
		self
	end
	# Positive definite hash?
	def coordinate_workers(wk1,wk2,dir)
		_workers_belong_to_me?(wk1,wk2) #This raises an error on failure
		@spacehash[[wk1.param,wk2.param]] = dir
		@spacehash[[wk2.param,wk1.param]] = (dir.is_a?(Fixnum))? 0 - dir : dir
		[wk1.param,wk2.param].flatten(1).each { |ele| (ele.is_a?(Class))? @sets.push(ele) : @instances.push(ele) if (@sets + @instances).index(ele).nil? }
	end
	def compare(s1,s2)
		s1 = [s1] unless s1.is_a? Array
		s2 = [s2] unless s2.is_a? Array
		for i in 0..([s1.length,s2.length].max)
			p1 = s1[(-1)..(-1 - i)].collect {|e| _get_closest_membership(e)}
			p2 = s2[(-1)..(-1 - i)].collect {|e| _get_closest_membership(e)}
			result = case @spacehash[  [ p1 , p2  ]  ]
				when Fixnum	 then @spacehash[[p1,p2]]
				when Symbol	 then  (0..i).inject(0) {|r,i2| (r == 0) ? s1[-1 - i2] <=> s2[-1 - i2] : r   } 
				when nil	 then (s1 == s2) ? 0 : nil 
				else 		 raise "Something Bad Happened. Not quite sure what..."
			end
			break if result != 0
		end
		result
	end
##### Instance methods 
	## Comparision generation
	# Calls the insertion function with spaceship operator values (1,0,-1) 
	#########
	## Space Level operators
	def cspace
		@space[@plvl]
	end
	private
	class Worker #Construction worker
		attr_reader :factory, :param
		def initialize(factory,args)
			@factory = factory
			@param = args
		end
		def <(obj); 	@factory.coordinate_workers(self,obj,-1); 	end
		def >(obj); 	@factory.coordinate_workers(self,obj,1); 	end
		def ===(obj);	@factory.coordinate_workers(self,obj,0); 	end
		def <=>(obj); 	@factory.coordinate_workers(self,obj,:<=>);		end
	end

	def _new_space
		{:uplvl => nil, :objs => [], :<=> => [], :max_repeat => 0 }
	end
	def _workers_belong_to_me?(wk1,wk2)
		raise "Attempted to generate a comparison space using *Worker*s bound 
			to different factories (or not bound to a factory). 
			#{wk1}.factory != #{wk2}.factory".delete("\t\n") if wk1.factory != wk2.factory || wk1.factory != self
	rescue NoMethodError => e
		raise e, "One of the input workers is not a #{self.class}::Worker." 
	end
	def _get_closest_membership(item)
		if @instances.index(item) 
			item
		else 
			@sets.find_all { |s| item.is_a? s }.sort[0] # Should be closest ancestor
		end
	end
	
end
