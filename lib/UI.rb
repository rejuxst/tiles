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
	def close
	end
	def setup
	end
	def take_turn
		Proc.new {}
	end
##### Required UI Channel interaction methods
	def inbound_package package
	end
	def outbound_package package
		@channel.outbound_package.call(package)
	end
	def request_inbound_package
		@channel.request_inbound_package.call
	end
	def channel=(channel)
		@channel= channel
	end
	private
	def channel
	end
end
class View
	def close; end
	def setup; end
	def receive_package(package); end
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
	def request_inbound_package
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
