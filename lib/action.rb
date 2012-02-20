require "generic"
class Action
	include Generic::Base
	include Generic::Respond_To
	attr_accessor :actor, :target
	attr_accessor :path, :with, :using
	attr_accessor :effects
	def self.inherited(subclass)
		Generic::Respond_To::Respond_To_Tree.add_class_to_list(subclass)
	end
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
			else
				raise "This is not a compatible type for Action.using"
		end
		return self
	end
	def on target
		@target = target
		return self
	end
	def preform
		begin
			preform_pre_callback
		rescue ActionCancel
			return nil
		end
		begin
		add_response(@using.response(@target.class,:using)) unless @using.nil?
		@path.each{ |t| add_response(t.response(self.class,:via))	} unless @path.nil?
		add_response(@target.response(@target.class,:target)) unless @target.nil?
		add_response(@with.response(@target.class,:with)) unless @with.nil?
		rescue ActionRevaluate => action
			return action.preform
		rescue ActionCancel
			return nil
		end
		return calculate
	end
	def calculate
	
	end
	def preform_pre_callback
	
	end
	def get_tile(tile)
		tile = tile.owner until tile.is_a? Tile
		return tile
	end
	def self.get_tile(tile)
		tile = tile.owner until tile.is_a? Tile
		return tile
	end
	def add_response(response)
		case 
			when response.is_a?(Array)
				@effects << response
			when response.is_a?(Property::Effect)
				@effects << response
			when response.is_a?(Proc)
				out = r.call(self)
			when response.is_a?(Symbol)
				case response
					when :none
					when :cancel
						raise ActionCancel, "One of the components of the Action canceled it"
					when :retry
				end
			when response == nil
				return nil
			else
		end
	end
	class ActionCancel < StandardError
	end
	class ActionRevaluate < StandardError
	end
end