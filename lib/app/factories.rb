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
##### Instance methods 
	## Comparision generation
	# Calls the insertion function with spaceship operator values (1,0,-1) 
	def >(value);	_insert_obj(value,1);	end 
	def ==(value);	_insert_obj(value,0);	end
	def <(value);	_insert_obj(value,-1);	end
	#########
	## Space Level operators
	def <<(obj)
		if obj.is_a? self.class
			@pointer = obj.pointer
			@splvl = @space.length + obj.splvl
			@space << obj.fspace	
		elsif obj.is_a? Class
			@space << obj
			@splvl = @space.length - 1
			@pointer = 0
		else
			raise "Can't append #{obj} obj must be a Class or another ComparableFactory" 
		end
	end
	def shift(space)
		if obj.is_a? self.class
			@pointer = obj.pointer
			@splvl = obj.splvl
			@space.shift  obj.fspace	
		elsif obj.is_a? Class
			@space.shift  obj
			@splvl = 0
			@pointer = 0
		else
			raise "Can't append #{obj} obj must be a Class or another ComparableFactory" 
		end
	end
	#######
	def <=>
		raise "Class is not Comparable is a Comparision construction class. The spaceship operator can only be used in conjunction with a proc"
	end
	def initialize(opts = {})	
		@name = opts[:name]
		@space = [[[  ]]]
		@splvl = 0
		@pointer = nil 
	end
	def generate()
	 	self.class.register_space @name, ComparisonSpace.new(@space)
	end
	def move_to(obj)
		@pointer = space.index { |eqset| eqset.index(obj) }
		raise "Unable to locate #{obj} in Factory may not have been included yet" if @pointer.nil?
		self
	end
	# operate on a set
	def set(array)
		raise "Input is not an array of already included objects" unless array.is_a?(Array) && 
							 array.all? { |a| space.flatten(1).any? { |c| c == a } }
		@pointer = array 
		self
	end
	def all_right_now
		set(:all)
		self
	end

	# operate on the set of all objects in the space. Operation on this will effect objects not yet in the space
	def all(); @pointer = :all;	self;		end
	# move to the lowest comparison set nothing else in the space currently returns true to min > obj
	def min(); @pointer = 0; 	self;		end
	# move to the maximum comparison set nothing else in the space currently returns true to max < obj
	def max(); @pointer = space.length - 1;  	end

	public
	def fspace
		@space
	end
	def space
		@space[@splvl]
	end
	def pointer
		@pointer
	end
	def splvl
		@splvl
	end
	private
	def _insert_obj(obj,dir)
	
		case pointer
			when nil then @pointer = 0; _merge(obj)
			when Fixnum # When we are pointing at a specific space insert or append based on direction (<,==,>)
				case dir
				 	when -1 then  space.insert(@pointer+1,[obj]); @pointer = @pointer + 1 # we generated a new space after pointer
					when 0  then  _merge(obj)			# Merge obj into space if obj exists merges the sets between obj and @pointer
				 	when 1 	then  space.insert(@pointer,[obj]) 	# We have generated a new set at @pointer 
				end
			when :all   then _general_modifier(value)			# A general modifier to the space 
			when Array  then _set_modifier(value)				# defines the action of a modifier on a set
		end
		self
	end

	def _merge(obj)
		unless (index = space.index { |a| !a.index(obj).nil? }).nil?
			# slices out the section between (and including) @pointer and index, flattens it and then replaces back at its old index
			space.insert(	(index<=pointer) ? index : pointer, 
					space.slice!({-1 => index..pointer, 0 => index, 1 => pointer..index}[index <=> pointer]).flatten(1)
					)
		else
			space[pointer].push obj	# obj doesn't exist in the space so append it at the current positoin
		end
	end
	private
	class ComparisonSpace
		def initialize(space)
			@space = space
			@hash = @space[0].each_index.inject({}) { |r,i| @space[i].each { |o| r[o] = i }; r }
		end
		def compare(in1,in2)
			@hash[in1] <=> @hash[in2] 
		rescue
			raise ArgumentError, "Comparison of #{in1.class} with #{in2.class} invalid."
		end
	end
end
