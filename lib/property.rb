require 'database'
class Property
	include Database
	def self.requires_value(name,value_class,*options)
		raise "Value can not be a database must be a primitive class i.e String,Symbol,Number" unless value_class.is_a? Class and !value_class.new.includes? Database
		@values = {} if @values.nil? 
		@values[name] = {:class => value_class}
	end
	def self.values
	#TODO: Scure this function
		return @values.nil? ? {} : @values
	end
	def initialize
		init_database
		self.class.values.each_pair do |ky,val|	
			key = add_to_db(val[:class].new)
			add_reference key,ky	
		end
	end
end
