#TODO: Deal with issues regarding class inheritance 
module Generic
	module Base
	#generic contains methods global to all instanciated objects
	include Database
		#note that 
		module Extentions
			include Database
			def add_properties(*args)
				@default_properties ||= (super.default_properties rescue @default_properties = [])
				args.each {  |p| @default_properties.push p }
				nil
			end
			def add_class_property(prop,value_hash = {})
				prop = eval("#{prop.to_s.capitalize}") unless prop.is_a? Class 
					#TODO: Switch to Dictionary lookup of property 
				instance = prop.new(value_hash)
				add_to_db(instance,prop.to_s.downcase)
				prop.required_references.each_pair do |name,params| 
					add_reference name,instance,&params		
				end
			end
			def default_properties
				@default_properties || []
			end
			def add_initialize_loop(*options,&blk)
				initialize_loops.push blk
			end
			def initialize_loops
				@initialize_loops ||= (self.superclass.initialize_loops() rescue @initialize_loops = []).dup
			end
			def enforce_reference(*ref_key)
				@enforcable_references ||= []
				ref_key.each{ |ref| @enforcable_references.push ref } 
				@enforcable_references.collect {|ref| ref}
			end
			def self.included(base)
				base.init_database
			end

		end	
	        def self.included(base)
			base.extend Extentions
		end
		def initialize(*args)
			init_database
			self.class.enforce_reference().each {|ref| self.add_reference ref, nil , :add_then_reference => true }
			self.class.initialize_loops.each {|loop| instance_exec *args, &loop} 
			self.class.default_properties.each {|prop| self.add_property(prop) }
			init(*args)
		end
		def init(*args)
		end
		def add_property(prop,value_hash = {})
		# add_property: Added the property prop to the database 
		#		Alias the internal varibles as defined by the property
		#	??	Add the support functions for the property to the object itself
			prop = ::Tiles::Application::ObjectSpace.lookup_class(prop.to_s.downcase) unless prop.is_a? Class 
				#TODO: Switch to Dictionary lookup of property 
			instance = prop.new(value_hash)
			add_reference prop.to_s.downcase,instance, :add_then_reference => true
			prop.required_references.each_pair do |name,params| 
				add_reference name,instance,&params		
			end
		end
	end
end
