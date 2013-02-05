require 'database'
module Generic
	module Base
	#generic contains methods global to all instanciated objects
	include Database
		#note that 
		module Extentions
			def add_properties(*args)
				@default_properties ||= (super.default_properties rescue @default_properties = [])
				args.each {  |p| @default_properties.push p }
				nil
			end
			def default_properties
				@default_properties || []
			end
			def add_initialize_loop(*options,&blk)
				initialize_loops.push blk
			end
			def initialize_loops
				@initialize_loops ||= (self.superclass.initialize_loops() rescue @initialize_loops = [])
			end
			def enforce_reference(*ref_key)
				@enforcable_references ||= []
				ref_key.each{ |ref| @enforcable_references.push ref } 
				@enforcable_references.collect {|ref| ref}
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
			prop = eval("#{prop.to_s.capitalize}") unless prop.is_a? Class 
				#TODO: Switch to Dictionary lookup of property 
			instance = prop.new(value_hash)
			add_to_db(instance,prop.to_s.downcase)
			prop.required_references.each_pair do |name,params| 
				add_reference name,instance,&params		
			end
		end
	end
	module Responsive
		module Extensions
		# @response is the class varible for response hash
		# via : 
		#
			def add_response(to,type,response)
			# add_response adds a response to an action to the calling class 
			# to => 	the action that this class will respond to
			# type => 	the category of interaction for this object (e.g :via, :using,:with,:target, etc.)
			# response => 	the action/equation/effect to be processed
			# options => 	additional options or information relavent to the process of calling  the response
			#######
			# Safety check on the inputs.
			to = to.to_s
			type = type.to_s
			raise "Invalid response cetegory for a response to an action" unless 
				%w[via using with target actor on].any?{ |cat| type == cat }  

			@response ||= {} 
			@response[to] ||= {} 
			@response[to][type] = (	response.is_a?(Hash) ) ?
						response[:effect] || response[:response] || response[:block]
						: response
			#binding.pry 
			end
			def response(action,as)
				# Returns the effects of the response to an action
				act_class = (action.is_a?(Class)) ? action : action.class
				unless @response.nil? || @response[act_class.to_s.downcase].nil?
					return @response[act_class.to_s.downcase][as.to_s] 
				end
				return self.superclass.response(action,as) rescue return nil
			end
		end
	        def self.included(base)
			base.extend Extensions
		end
		def response(action,as)
			# Returns the effects of the response to an action
			act_class = (action.is_a?(Class)) ? action : action.class
			unless @response.nil? || @response[act_class.to_s.downcase].nil?
				return @response[act_class.to_s.downcase][as.to_s] 
			end
			return self.class.response(action,as)
		end
		
	end
end
