class Property < ::Tiles::BasicObject
###### Initialization ###################
	add_initialize_loop do |*args| 
		self.class.values.each_pair do |name,params| 
			add_variable name , 
				params[:initially] || (params[:class].new rescue nil) 
		end
	end
###### Class Methods ####################
	def self.requires_value(name,value_class,opts = {})
		values[name] = {:class => value_class, :initially => opts[:initially]}
	end
	def self.requires_reference(name,&blk)
		(@references ||= {})[name] = blk || nil
	end
	def self.requires_variable_alias(name,var_name,opts = {})
		requires_reference(name) {|src,tar| tar["#{var_name}"] }
	end
	def self.values #TODO: Secure this function
		@values ||= {}
	end
	def self.add_properties
		raise "Can't add or default a property to contain properties"
	end
	def self.required_references
		@references ||= {}
	end
#########################################
##### Instance methods ##################
	def add_property(*args)
		raise "Cant add a property to a property"
	end

	def []=(ky,value)
		self.db_get(ky).set value, :ignore_if => :constant
	end
end
