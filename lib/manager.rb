if !defined? Tiles
module Tiles ; end
end
if !defined? Tiles::Application
module Tiles::Application ; end
end
class Tiles::Application::Manager

	private :method
	private :send 
	private	:singleton_class
	private :singleton_method_removed
	private	:singleton_method_added
	########
	public	
	#######
	def create_connection(ui,channel_class)
		raise "Input UI is not a UI it is a #{ui.class}" unless ui.is_a? UI
		if valid_channels.has_key channel_class
			key= 0 
			key= Random.new(object_id).rand(1000000) while key != 0 && channel_instances.has_key?(key)
			channel_instances[key] = valid_channels[channel_class].call(ui.method(:inbound_package))
			outbound = (method :outbound_package)
			ui.outbound_package_method= lambda { |package| outbound.call(key,package) }
			true
		else
			false
		end
	end
	def register_new_channel(channel_class, channel_class_new)
		valid_channels[channel_class.to_s] = channel_class_new.to_proc
		true
	end

	def initialize(opts = {})
	end
	private
	def outbound_package(key_target,package)
		#raise "Too many invalid key access attempts" if invalid_count > 1000
		#return add_invalid_count unless channel_instances.has_key? key_target
		channel_instances[key_target].outbound_package package
		#reset_invalid_count
	end
#	def add_invalid_count
#		(@invalid = (@invalid || 0) + 1) == 0
#	end
#	def reset_invalid_count
#		(@invalid = 0) == 0
#	end
#	def invalid_count
#		@invalid ||= 0
#	end
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
