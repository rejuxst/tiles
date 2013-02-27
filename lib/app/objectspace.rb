class Tiles::Application::ObjectSpace < ::BasicObject # Partial Security and Uninstaiated
	SUPPORTED_BASE_CLASSES = [::Hash, ::Array,::String].freeze
	def self.register_basicobject_class(cl)
		raise "input is not a class is a #{cl.class}" unless cl.is_a? ::Class
		@class_list ||= {}
		@class_list[cl.name.downcase] = cl
	end
	def self.lookup_class(cl)
		case cl
			when ::String then @class_list[cl.to_s.downcase] 
			when ::Class  then @class_list[cl.name.downcase] ||  SUPPORTED_BASE_CLASSES.find { |c| c.name === cl.name }
			else 		   @class_list[cl.to_s.downcase] || SUPPORTED_BASE_CLASSES.find { |c| c.name === cl.to_s }
		end
	rescue
		raise "Unable to lookup given class #{cl} is a #{cl.class}. Expected input cast to string to return a valid class name"
	end
	def self.register_instance()
	end
	private
	def self.destroy_instance_record()
	end
end
