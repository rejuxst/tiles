require "generic"
require 'pry'
class Action
	include Generic::Base
	def init(args = {})
		args = args[0] if args.is_a? Array
		effects = []
		from(args[:actor])
		on(args[:target])
		with(args[:with])
		using(args[:using])
		via(args[:path])
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
	def from(actor = nil)
		return self["actor"] if actor.nil?
		add_reference("actor",actor)
		return self
	end
	def with(with = nil)
		return self["with"] if with.nil?	
		add_reference("with",with)
		return self
	end
	def using(use = nil)
		return self["using"] if use.nil?
		add_reference("use",use)
		return self
	end
	def on(target = nil)
		return self["target"] if target.nil?
		add_reference("target",target)
		return self
	end
	def preform
		preform_pre_callback
		add_response(using.response(self,:using)) unless using.nil?
		@path.each{ |t| add_response(t.response(self,:via))	} unless @path.nil?
		add_response(on.response(self,:target)) unless on.nil?
		add_response(with.response(self,:with)) unless with.nil?
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
