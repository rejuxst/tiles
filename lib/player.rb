require "active"
require "generic"
require "UI"
class Player
	include Generic::Base
	include Active

	attr_reader :ui
	add_initialize_loop do |arghash = {}|
		add_reference_set 	"controls",[],:add_then_reference => true
		@ui ||= arghash[:ui]
		ui.owner = self unless ui.nil? 
	end
	def take_turn
		if !ui.nil?		
			ui.render
			event = ui.getevent
			process_event event
		end
		turn.value= turn + 1
	end
	def process_event event
	end
	def take_control item, opts = {}
		item.controller= self
#		item.move_self_to_db(self)
		add_reference opts[:reference], item unless opts[:reference].nil?
		controls.add item

	end
end	
