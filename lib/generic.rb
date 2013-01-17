require 'database'
module Generic
	module Base
	#generic contains methods global to all instanciated objects
	include Database
		module Extentions
			def add_properties(*args)
				if @default_properties.nil?
					@default_properties = super.default_properties rescue @default_properties = []
				end
				args.each do  |p|
					@default_properties.push p
				end
				return nil
			end
			def default_properties
				return (@default_properties.nil?) ? [] : @default_properties
			end
			def add_initialize_loop(*options,&blk)
				if @initialize_loops.nil?
					@initialize_loops = self.superclass.initialize_loops() rescue @initialize_loops = []
				end
				@initialize_loops.push blk
			end
			def initialize_loops
				@initialize_loops.nil? ? @initialize_loops : []
			end
			def enforce_reference(ref_key)

			end

		end	
	        def self.included(base)
			base.extend Extentions
		end
		def initialize(*args)
			init_database
			self.class.default_properties.each {|prop| add_property(prop) }
			self.class.initialize_loops {|loop| instance_exec args, &loop} 
			init(*args)
		end
		def init(*args)
		end
		def add_property(prop,value_hash = {})
		# add_property: Added the property prop to the database 
		#		Alias the internal varibles as defined by the property
		#	??	Add the support functions for the property to the object itself
		prop = eval("#{prop.to_s.capitalize}") unless prop.is_a? Class #TODO: Switch to Dictionary lookup of property 
		add_to_db(prop.new(value_hash),prop.to_s.lower)
		prop.required_references {|name,blk| (blk.nil? || blk == true) ? add_reference(prop,name) : add_reference(prop,name) &blk }
		end
	end
	module Responsive
		module Extensions
		# @response is the class varible for response hash
		# via : 
		#
			def add_response(to,type,response,options = {})
			# add_response adds a response to an action to the calling class 
			# to => 	the action that this class will respond to
			# type => 	the category of interaction for this object (e.g :via, :using,:with,:target, etc.)
			# response => 	the action/equation/effect to be processed
			# options => 	additional options or information relavent to the process of calling  the response
			#######
			# Safety check on the inputs. 
			to = "#{to}".downcase.to_sym
			type = type.to_sym
			raise "Invalid response cetegory for an reponse to an action" if type.nil? 
			#TODO: Fix this if statement to cover the categories of action responses
			@response = {} if @response.nil?
			@response[to] = {} if @response[to].nil?
			@response[to][type] = response
			end
			def response(action,as)
				# Returns the effects of the response to an action
				act_class = action
				act_class = action.class unless action.is_a?(Class)
				unless @response.nil? || @response["#{act_class}".downcase.to_sym].nil?
					return @response["#{act_class}".downcase.to_sym][as] 
				end
				return self.superclass.response(action,as) rescue return nil
			end
		end
	        def self.included(base)
			base.extend Extensions
		end
		def response(action,as)
			# Returns the effects of the response to an action
			act_class = action
			act_class = action.class unless action.is_a?(Class)
			unless @response.nil? || @response["#{act_class}".downcase.to_sym].nil?
				return @response["#{act_class}".downcase.to_sym][as] 
			end
			return self.class.response(action,as)
		end
		
	end
end
