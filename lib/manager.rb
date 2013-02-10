if !defined? Tiles
module Tiles ; end
end
if !defined? Tiles::Application
module Tiles::Application ; end
end

class Tiles::Application::Security < BasicObject
	class SecurityFault < ::Exception; end
	def self.destructive_secure_class( cls )
		[ :method, :send, :singleton_class, 
		  :singleton_method_removed, :singleton_method_added, 
		  :define_singleton_method
		].each do |meth|
		cls.define_singleton_method( meth ) { raise SecurityFault, "class has been secured" } rescue nil
		end
		cls
	end
	def self.destructive_secure_method( mobj )
		[ :method, :send, :public_send ,
		  :instance_variables,:instance_variable_get,
		  :receiver, :source,
		  :instance_eval, :instance_exec,
		  :singleton_class,  :define_singleton_method
		].each do |meth|
		mobj.define_singleton_method( 
				meth 
			) { raise SecurityFault, "method object has been secured" } rescue nil
		end
		mobj
	end
end
class Tiles::Application::Manager
	ChannelMethodPackage= Struct.new(
		:request_inbound_package,
		:outbound_package,
		)
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
		if valid_channels.has_key? channel_class
			key= 0 
			key= Random.new(object_id).rand(1000000) while key != 0 && channel_instances.has_key?(key)
			channel_instances[key] = valid_channels[channel_class].call(ui.method(:inbound_package))
			outbound = (method :outbound_package)
			ui.channel= create_channel_method_package(channel_instances[key])
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
	def create_channel_method_package(channel)
		ChannelMethodPackage.new(
		Tiles::Application::Security.destructive_secure_method(channel.method :request_inbound_package ),
		Tiles::Application::Security.destructive_secure_method(channel.method :outbound_package)
		)
	end
	def outbound_package(key_target,package)
		#raise "Too many invalid key access attempts" if invalid_count > 1000
		#return add_invalid_count unless channel_instances.has_key? key_target
		channel_instances[key_target].outbound_package package
		#reset_invalid_count
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
