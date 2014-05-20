require 'pry'
class Thing < ::Tiles::BasicObject
	include Generic::Responsive

	# hash of all applicable state information with the key being an element on the definition database
	# and the value being either dynamically or statically defined
	# FIXME: Rendering as an attr is terrible and contrary to the model
	attr_reader :ASCII

	add_initialize_loop do |args = {}|
		@ASCII = '0'
		@ASCII = args[:ASCII] if !args[:ASCII].nil?
		args[:controller].take_control(self) if !args[:controller].nil?
	end

	def controller
		db_get "controller"
	end

	def controller=(contrl)
		controller.controls.delete(self) unless controller.nil?
		add_reference "controller",contrl
		controller
	end
end
