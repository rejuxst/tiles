require "generic"
class Action
	include Generic::Base
	include Generic::Responsive
	attr_accessor :actor, :target
	attr_accessor :path, :with, :using
	attr_accessor :effects
	def initialize(args = {})
		@effects = []
		@actor = args[:actor]
		@target = args[:target]
		@with = args[:with]
		@using = args[:using]
		via args[:path]
		init
	end
	def init
	
	end
	def via path
		@path = []
		if path.is_a? Array
			@path = path 
		else
			@path << path
		end
		return self
	end
	def from(actor)
		@actor = actor
	end
	def with with
		@with = with
		return self
	end
	def using use
		case use.class
			when NilClass
			when Thing
			when Array
			when Hash
			else	raise "This is not a compatible type for Action.using"
		end
		return self
	end
	def on target
		@target = target
		return self
	end
	def preform
		preform_pre_callback
		add_response(@using.response(self,:using)) unless @using.nil?
		@path.each{ |t| add_response(t.response(self,:via))	} unless @path.nil?
		add_response(@target.response(self,:target)) unless @target.nil?
		add_response(@with.response(self,:with)) unless @with.nil?
		return calculate
	rescue ActionRevaluate => action
		return action.preform
	rescue ActionCancel
		return nil
	end
	def calculate
	
	end
	def preform_pre_callback
	
	end
	def add_response(response)
		case response
			when Array 		then	@effects << response
			when Property::Effect	then	@effects << response
			when Proc 		then 	out = r.call(self)
			when Symbol
				case response
					when :none
					when :cancel	then raise ActionCancel, "One of the components of the Action canceled it"
					when :retry
				end
			when NilClass 		then	return nil
			else
		end
	end
	class ActionCancel < StandardError
	end
	class ActionRevaluate < StandardError
	end
end
