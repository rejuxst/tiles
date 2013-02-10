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
##### Required UI Channel interaction methods
	def inbound_package package
	end
	def outbound_package package
		@send_package_method.call package
	end
	def send_package_method= method
		@send_package_method= method.to_proc
	end
end
class View
end
class Channel
	private_class_method :new
	def self.new_channel_creation
		lambda { |ui_inbound| new ui_inbound }
	end
	def outbound_package package
		sanitize package
	end
	def inbound_package package
		@inbound.call(sanitize( package ) )
	end
	def initialize(ui_inbound)
		@inbound = ui_inbound.to_proc
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
