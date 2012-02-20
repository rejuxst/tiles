module Generic
	module Extend

		def self.inherited(subclass)
			Respond_To::Respond_To_Tree.add_class_to_list(subclass)
		end
	end
	module Base
	#generic contains methods global to all instanciated objects
		attr_accessor :owner, :things, :properties	
		def giveto stuff
			if !((stuff.constants.find {|s| s.contains "things"}) == nil)
				owner.things.delete_if {|t| t == self} if !owner.nil?
				@owner = stuff 
				stuff<< self
			else
				raise "You are trying to give a #{self.class.to_s} to a #{self.class.to_s}"
			end
		end
		def self.db_prop_add(*args)
			args.each{ |p|
				prop_s = p.to_s
				Database::Global.add_to_definition(self,prop_s,:property)
			}
		end

		def take item
			if !item.owner.nil?
				i = item.owner.things.delete(item)
			end
			item.owner = self
			self.things << item
			return self
			raise "Can't take something that is not an item"
		end
		
		def <<(stuff)
			return take(stuff) if stuff.class <= Thing
		end

	end
	module Respond_To
	# Reserved symbols => :super, :all, :via, :default, :with, :using
	# Reserved Actions => Action, Effect?
		def self.included(base)
			Respond_To_Tree.add_class_to_list(base)
			class_str = "def self.class_responds_to(action,as,blk)
					Generic::Respond_To::Respond_To_Tree.respond_to(self,action,as,blk)
				end"
			base.module_eval(class_str)
		end 
		def respond_to(action,as,blk) # Blk checks ned to be added blks need to be added as lambdas
			raise "Block passed was not a lambda" if !(blk.class <= Proc) || blk.lambda? 
			if action.class <= Action
				action = eval(":#{action}")
			else
				unless action.class <= Symbol || action.class <= String
					raise "Invalid Action type: #{action}" 
				end
			end
			@respond_to = {} if @respond_to.nil?
			@respond_to[action] = {} if @respond_to[action].nil?
			@respond_to[action][as] = blk

		end
		def response(action,as)
			# action should be an Action inheritor and as should be :target, :via, :with, or :using
			# (as can be a symbol or string). This will pass back a packaged action
			return Respond_To_Tree.response(self.class,action,as) 		if @respond_to.nil?
			return Respond_To_Tree.response(self.class,action,as)		if @respond_to[action].nil? && @respond_to[:unknown] == :super
			as = :all													if !@respond_to[action][:all].nil?
			case @respond_to[action][as].class
				when Symbol	
					return Respond_To_Tree.response(self.class,action,as)  	if @respond_to[action][as] == :super
					return nil 												if @respond_to[action][as] == :none
				when NilClass						# This item doesn't have a specific response check the class
					return Respond_To_Tree.response(self.class,action,as) 
				else
					return @respond_to[action][as]	# compatability check should happen at the respond_to function
			end
				
		end
		class Respond_To_Tree
			@@respond_to = {}
			def self.add_class_to_list(inclass)
				classname = :"#{inclass}"
				@@respond_to[classname] = {:unknown => :super}
				@@respond_to[classname][:action] 			= {}
				@@respond_to[classname][:action][:with] 	= nil	# The response of this object to an Action :with self
				@@respond_to[classname][:action][:target] 	= nil	# The response to an Action when self is the :target
				@@respond_to[classname][:action][:via]	 	= nil	# The response to an Action when :target is reached :via self
				@@respond_to[classname][:action][:all] 		= nil
				@@respond_to[classname][:action][:using] 	= nil
				@@respond_to[classname][:unknown] 			= :super # Respond to an unknown action with the response associated with its superclass

			end
			def self.get_tree
				return @@respond_to
			end
			def self.response(inclass,action,as)
				classname = :"#{inclass}"
				action = :"#{action}"
				as = :"#{as}"
				return nil if inclass.superclass == Object.superclass	# This allows modifying Global Object response
				return self.response(inclass.superclass,action,as) 	if @@respond_to[classname].nil?	# class doesn't exist
				return self.response(inclass.superclass,action,as) 	if @@respond_to[classname][action].nil? && @@respond_to[classname][:unknown] == :super # action doesn't exist
				as = :all	if !@@respond_to[action][:all].nil?
				case @@respond_to[classname][action][as].class
					when Symbol	
						return self.response(inclass.superclass,action,as)	if @respond_to[action][as] == :super
						return nil 											if @@respond_to[classname][action][as] == :none
					when NilClass						# This item doesn't have a specific response check the superclass
						return self.response(inclass.superclass,action,as)
					else
						return @@respond_to[classname][action][as]	# Checks should happen at the respond_to function
				end
			end
			def self.has_response?(inclass)
				classname = :"#{inclass}"
				return true unless @@respond_to[classname].nil?
				return false
			end
			def self.respond_to(inclass,action,as,blk)
				action = :"#{action}"
				self.add_class_to_list(inclass) unless self.has_response?(inclass)
				@@respond_to[:"#{inclass}"][action] = {} if @@respond_to[:"#{inclass}"][action].nil?
				@@respond_to[:"#{inclass}"][action][as] = blk
			end
		end
	end
end