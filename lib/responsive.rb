require 'generic'
require 'database'
require 'reference'
module Generic::Responsive
	module Extensions
	end
	def self.included(base)
		base.extend self
	end
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
	@response_db ||= Database.new
	@response_db.add_response(to,type,
					(	response.is_a?(Hash) ) ?
					response[:effect] || response[:response] || response[:block]
					: response
				)
	end
	def response(action,as)
		# Returns the effects of the response to an action
		act_class = ((action.is_a?(Class)) ? action : action.class).name.downcase
		as = as.to_s.downcase
		@response_db ||= Database.new
		case self
			when Class then @response_db[act_class,as] || self.superclass.response(action,as)
			when Object then @response_db[act_class,as] || self.class.response(action,as)
		end rescue nil
	end

end
class Generic::Responsive::Database
	include Database
	def initialize
		init_database
	end
	def [](*ind)
		a = super(*ind)
		if a.nil? || !a.is_a?(::Database::Reference)
			a
		else  
			a.resolve
		end
	end
	def add_response(to,type,response)
		to = to.to_s.downcase
		type = type.to_s.downcase
		add_reference_set(to.to_s,[]) if  db_get(to).nil? 
		db_get(to)[type]= ::Generic::Responsive::Response.new self,response	
	end
end
class Generic::Responsive::Response < ::Database::Reference::Variable
	def resolve
		@var
	end
end
