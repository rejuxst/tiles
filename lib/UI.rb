require 'database'
# Core access methodology:
# 
class UI
# UI should contain:
# Outbound translator (Outbound from the game)
# Inbound translator  (Inbound from the game)
# Channel (Like a translator but non-modifiable or creatable from a UI)
# 
	attr_accessor :owner
	def initialize
		
	end
	def render
	end
	def close
	end
	def getevent
	end
	def setup
	end
end
class View
end
class Channel
	def request_input_from_end_user()
		# This depends on the targetted end user profile
	end
	def send_to_end_user(output)
		# This depends on the targetted end user profile
	end
	def send_to_ui(input_stream)
		@ui.send(sanitize(input_stream))
	end
	########
	protected
	########
	def initialize(ui_inbound,ui_outbound)
		raise "Target_ui is not a UI it is a #{target_ui.class}" unless target_ui.is_a? UI
		@ui = target_ui
		@profile = target_user_profile
	end
	#######
	protected
	#######
	def sanitize(stream)
		stream
	end
end
class Translator
	include Database
	def translate package
	end
end
