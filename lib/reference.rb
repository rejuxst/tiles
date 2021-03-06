require 'pry'
require 'database'
# TODO: Set shoudl probably become a database itself because there is a clear need for 
#	References to be blank (with a key). For Example lets say the game wants a list of all
#	objects 'controlled' by all the players there would need to be a bunch of references 
#	that the game doesn't need to know about but have to exist to maintain connectivity
class Database::Reference
	@@valid_reference_classes = [String, Class]
	def self.add_valid_reference_class(the_class)
		raise "Not a class #{the_class.class}" if not the_class.is_a? Class
	end
	def self.is_valid_reference_class(the_class)
		@@valid_reference_classes.any? {|cl| cl == the_class}
	end

	def what_died?
		return @source if not @source.db_alive? 
		return @target if resolve.nil?
		return nil
	end
	def initialize(source,target,opts = {}, &blk)
                # Input validation checks
		raise "Source location is not a Database Reference cannot be generated" if !Database.is_database?(source)
#		raise "Target location is not a Database Try making a local reference" if !Database.is_database?(target)
                @source = source
		@target = target
		@blk    = opts[:proc] || blk
	end
	def resolve
		return @blk.call(@source,@target) unless @blk.nil?
		return @target if @target.db_alive? and @source.db_alive? rescue nil
		nil
	end
	class Chain < ::Database::Reference
		def initialize(source,target_chain,opts = {}, &blk)
		raise "Source location is not a Database Reference cannot be generated" if !Database.is_database?(source)
			target_chain = [target_chain] if not target_chain.is_a? Array
			@source = source
			@target_chain = target_chain
			unless @target_chain.all? {|element| Database.is_database_entry_class?(element.class)}
				raise "Invalid Reference::Chain element in chain #{@target_chain}"
			end
			#raise "Unable to resolveto non-nil object on first try" if resolve().nil?
		end
		def resolve
			local_varible = [@source]
			@target_chain.each do |ele| 
				next_varible = []
				local_varible.each{|var| next_varible << var[ele] unless var.nil? }
				local_varible = next_varible
			end
			return (local_varible.length < 2) ? local_varible[0] : local_varible
		end
	end
	class Collection < ::Database::Reference

		def initialize(source,target,opts = {}, &blk)
			raise "Source location is not a Database Reference cannot be generated" if !Database.is_database?(source)
			raise "Input is not a set of values collection should be an Array is a #{collection.class}" if !collection.is_a? Array	
			@source = source
			@collection = collection
		end
		def resolve #TODO: How to add and remove from a collection 
			#Set.new self , 
			@collection.collect {|item| item.is_a? Reference ? item.resolve : item }.delete_if {|i| i.nil?}
		end

	end
	class Set < ::Database::Reference
		include Enumerable
		def initialize(source, data, opts = {})
			@source = source
			@hash = {}
			i = -1
			case data
				when Array then data.each { |d| add d, :key => (i += 1) } 
				when Hash  then data.each_pair { |k,d| add d, :key => k }
				else 
				raise "Input initialization set is not a Array or Hash when creating #{self.class}"
			end
		end
		def each &blk
			@hash.each do |key,ele| 
				next unless !ele.respond_to?(:db_alive?) || ele.db_alive?() 
				if block_given?  
					(blk.parameters.length < 2) ? blk.call(ele) : blk.call(key,ele)
				else
					yield(key,ele) 
				end
			end
		end
		def <<(item)
			add(item)
		end
		def [](*ind)
			index(*ind)
		end
		def []=(*ind,value)
			#NOTE: Not sure if this should be a valid semantic
			add(value, :key => ind)
		end
		def index(*ind)
			ele = @hash[ind]
			( ele.respond_to?(:db_alive?) && ele.db_alive?() ) ? ele : nil
		end
		def add(item, opts = {})
			item = @source.add_reference_set(nil,item) and 
				opts[:key] ||= opts[:make_subset] unless opts[:make_subset].nil?
			@source.add_to_db(item) if item.db_parent.nil?
			@hash[ 
				case opts[:key]
					when nil then  	[empty_key ]
					when Array then  opts[:key]
					else	    	[opts[:key]]
				end 
			] = item
			self
		end
		def delete(object)
			@hash.delete_if	{ |k,v| object == k or object == v} 
		end
		def resolve
		#	@hash.delete_if do |k,ele| 
		#		!ele.db_alive? || 
		#		(ele.is_a?(::Database::Reference) && ele.db_parent != self.db_parent)
		#	end
			self
		end
		def what_died?
			return @source if not @source.db_alive? 
			return @target if resolve.nil?
			return nil
		end
		def db_parent
			@source
		end
		def db_alive?
			@source.db_alive?
		end
		private 
		def empty_key
			i = 0;  (i  += 1) while hash.has_key? i
			i
		end
		def hash
			@hash ||= {}
		end
	end
	class Variable < ::Database::Reference
		include Comparable
		attr_reader :db_parent
		def db_alive?
			true
		end
		def value
			@var
		end
		def value=(input)
			@var = input if Variable.valid_class?(input)
			@var = input.value if input.is_a? Variable
		end
		def set(input,opts = {})
			self.value = input
		end
		def initialize(parent,var)
			raise "Invalid Datatype: #{var.class}" unless Variable.valid_class?(var)
			@db_parent = parent
			@var = var
		end
		def resolve
			return self
		end
		def <=>(other)
			@var.<=> other
		end
		def ===(other)
			@var.=== other
		end
		def method_missing(method_sym,*arguments,&block)
			if @var.respond_to?(method_sym)
				define_singleton_method( 
					method_sym.to_sym , 
					Proc.new {|*args,&blk| 	@var.send(method_sym.to_sym,*args,&blk) }
					)
				self.send(method_sym.to_sym,*arguments,&block)
			else
				super
			end
		end
		def self.valid_class?(var)
			[NilClass,Numeric,String,Symbol].any? { |c| var.is_a? c}
		end
	end
end
