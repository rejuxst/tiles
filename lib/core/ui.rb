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
	def outbound_package=(input)
		@outbound_package = input.to_proc
	end
	def outbound_package package
		@outbound_package.call(package)
	end
	def request_inbound_package=(input)
		@request_inbound_package = input.to_proc
	end
	def request_inbound_package
		@request_inbound_package.call
	end
	private

end
class View
	def close; end
	def setup; end
	def render; end
end
class Channel
	def outbound_package package
		sanitize package
	end
	def inbound_package= meth
		@inbound = meth.to_proc
	end
	def inbound_package package
		@inbound.call(sanitize( package ) )
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
