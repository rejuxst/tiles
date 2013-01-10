require 'database'
class Property
	include Database
	def self.requires_value(name,value_class,*options)
		raise "Value can not be a database must be a primitive class i.e String,Symbol,Number" unless value_class.is_a? Class and !value_class.new.includes? Database
		@values = {} if @values.nil? 
		@values[name] = {:class => value_class}
	end
	def self.values
	#TODO: Secure this function
		return @values.nil? ? {} : @values
	end
	def initialize(value_hash = {})
		init_database
		self.class.values.each_pair do |name,params|	
			key = add_to_db(params[:class].new,name)
		end
	end
	def []=(ky,value)
		add_to_db(value,key) #TODO: Should this really work and not throw an error?
	end
end
