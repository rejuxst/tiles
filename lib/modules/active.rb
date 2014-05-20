require 'pry'
module Active
	def take_turn;	end
	def self.included(base)
		raise "Generic may not have been included before Active
			. Unable to setup".delete("\n\r\t") unless base.respond_to? :add_initialize_loop
		base.add_initialize_loop do |*args|
			add_variable 		"turn", 0
		end
	end
end
