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
		end

	        def self.included(base)
			base.extend Extentions
		end
	end
	module Responsive
		module Extensions
		# @response is the class varible for response hash
		# via : 
		#
			def add_response(to,type,response,options = {})
			# add_response adds a response to an action to the calling class 
			# to => the action that this class will respond to
			# type => the category of interaction for this object (e.g :via, :using,:with,:target, etc.)
			# response => the action/equation/effect to be processed
			# options => additional options or information relavent to the process of calling  the response
			#######
			# Safety check on the inputs. 
			to = "#{to}".downcase.to_sym
			type = type.to_sym
			raise "Invalid response cetegory for an reponse to an action" if type.nil? #TODO: Fix this if statement to cover the categories of action responses
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
