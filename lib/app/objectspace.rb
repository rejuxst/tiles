class Tiles::Application::ObjectSpace < ::BasicObject #TODO: Partial Security and no new function
	SUPPORTED_BASE_CLASSES = [::Hash, ::Array,::String].freeze
	def self.register_basicobject_class(cl)
		raise "input is not a class is a #{cl.class}" unless cl.is_a? ::Class
		@class_list ||= {}
		@class_list[cl.name.downcase] = cl
	end

	def self.lookup_class(cl)
		case cl
			when ::String then @class_list[cl.to_s.downcase] 
			when ::Class  then @class_list[cl.name.downcase] || SUPPORTED_BASE_CLASSES.find { |c| c.name === cl.name }
			else 		   @class_list[cl.to_s.downcase] || SUPPORTED_BASE_CLASSES.find { |c| c.name === cl.to_s }
		end
	rescue
		raise "Unable to lookup given class #{cl} is a #{cl.class}. Expected input cast to string to return a valid class name"
	end

	def self.register_instance(instance)
		raise "Class not listed for instance #{instance.to_s}" if lookup_class(instance.class).nil?
		@instance_list ||= {}
		@instance_list[blank_id] = instance
		instance
	end

	def self.lookup_instance(key)
		(@instance_list[key] ) ? @instance_list[key] : nil
	end

	private
	def self.destroy_instance_record(instance,record_num)
		@instance_list[record_num] = false
	end

	def self.blank_id
		@max_id ||= 0
		@max_id= @max_id + 1 while @instance_list.has_key? @max_id
		@max_id		
	end
end

class Tiles::ClassSpace < ::BasicObject

	def self.register_class(cl)
		raise "input is not a class is a #{cl.class}" unless cl.is_a? ::Class
		@class_list ||= {}
		@class_list[cl.name.downcase] = cl
	end

	def self.lookup_class(cl)
		case cl
			when ::String then @class_list[cl.to_s.downcase] 
			when ::Class  then @class_list[cl.name.downcase] || SUPPORTED_BASE_CLASSES.find { |c| c.name === cl.name }
			else 		   @class_list[cl.to_s.downcase] || SUPPORTED_BASE_CLASSES.find { |c| c.name === cl.to_s }
		end
	rescue
		raise "Unable to lookup given class #{cl} is a #{cl.class}. Expected input cast to string to return a valid class name"
	end
end
