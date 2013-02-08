if !defined? Tiles
module Tiles ; end
end
if !defined? Tiles::Application
module Tiles::Application ; end
end
class Tiles::Application::Manager

	def create_connection(ui,channel_class)
		raise "Input UI is not a UI it is a #{ui.class}" unless ui.is_a? UI
		if valid_channels.has_key channel_class
			channel_instances[ui] = valid_channels[channel_class].call(ui.method(:inbound_package))
			true
		else
			false
		end
	end
	def regisier_new_channel(channel_class_new)
		valid_channels[channel_class.name] = channel_class
		true
	end
	def outbound_message(ui,package)
		channel_instances[ui].outbound_package package
	end
	private 
	def initialize(opts = {})
		# Securing a Manager instance
		[
		:method, :send, 
		:singleton_class, :singleton_method_removed, :singleton_method_added
		:private,:public
		].each { |meth| private meth } 
	end
	def valid_channels
		@valid_channels ||= {}
	end
	def freeze_channel_list
		@valid_channels.freeze
	end
	def channel_instances
		@channel_instances ||= {}
	end
end
