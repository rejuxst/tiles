class Action < Event

	# Action Configuration 
	extend ::Tiles::Configurable

	def self.add_action_category(*args)
		#raise "Entry is not an acceptable Database recordable entity" if 
		@action_categories = (@action_categories || []) + args 
	end
	def self.categories
		@action_categories || []
	end

	configuration_method :add_action_category

	default_configuration_call(:add_action_category,
			'on','actor','target','with','using','via')
	#################
	add_initialize_loop do |*args| 
		add_reference_set 'effects', [] , :add_then_reference => true
		Action.categories.each { |cat| add_reference cat, nil } 
	end
	def init(args = {})
		args = args[0] if args.is_a? Array
		(args || {}).each_pair do |key,val| 
			add_reference 	  key,val,:if_in_use => :destroy_entry unless 	val.is_a? Array
			add_reference_set key,val,:if_in_use => :destroy_entry if 	val.is_a? Array	
		end
	end
	def preform
		preform_pre_callback
		Action.categories.each do |cat|
			entry = self[cat]
			next if entry.nil?
			if entry.is_a?( ::Database::Reference::Set)
				entry.each { |t| add_response(t.response(self,cat)) }	
			else
				add_response(entry.response(self,cat))			
			end
		end
		effects.each { |effect| effect.resolve(self) }
		calculate 
	rescue ActionRevaluate => action
		return action.preform
	rescue ActionCancel
		return nil #TODO: BIG issue here. If an action is canceled the eventhandler
			   # 	  isn't told. As a result an actor's turn counter can become 
			   #	  desynced as everyone else is taking turns and not the actor
	end
	def calculate
	
	end
	def preform_pre_callback	
	end
	def add_response(response)
		case response
			when Array 	then	response.flatten.each { |r| add_response r }
			when Effect	then	effects << Effect.new(response.to_s)
			when String	then 	effects << Effect.new(response.to_s)
			when Proc 	then 	effects << BlockEffect.new(response)
			when :none
			when :cancel	then	raise ActionCancel, "One of the components of the Action canceled it"
			when :retry
			when nil 	then	return nil
			else		
		end
	end
	class ActionCancel < StandardError
	end
	class ActionRevaluate < StandardError
	end
end
