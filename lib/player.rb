require "active"
require "generic"
require "UI"
class Player
	include Active
	include Generic::Base
	attr_accessor :ui, :controls
	
	def initialize(arghash)
		@turn = 0
		@controls = []
		@ui = arghash[:ui] unless arghash[:ui].nil?
		@ui.owner = self unless @ui.nil? 
	end
	def take_turn
		if !@ui.nil?		
			@ui.render
			event = @ui.getevent
			process_event event
		end
		@turn +=1
	end
	def process_event event
#			x = 0
#			y = 0
#			i = true
#			i=Move.down(@controls[0])  if event == 119
#			i=Move.left(@controls[0])	 if event == 100 
#			i=Move.right(@controls[0]) if event == 97
#			i=Move.up(@controls[0])  	 if event == 115
#			process_event(@ui.getevent) if i.nil?
			#@controls[0].owner.offset(y,x) << @controls[0]
	end
	def take_control item
		if !item.controller.nil?
			!item.controller.controls.delete(item)
		end
		item.controller = self
		@controls << item
	end
end

		
