module Tiles; end
class Tiles::Application
	private :method
	private :send 
	private	:singleton_class
	private :singleton_method_removed
	private	:singleton_method_added
	def initialize(opts = {},&blk)
		opts[:valid_channels].each { |ch| register_new_channel_class ch } if (opts[:valid_channels] || "").is_a? Array
		@game = opts[:game]
		yield @game,self if block_given?
		@configuration= Tiles::Application::Configuration.last_config || 
				Tiles::Application::Configuration.use_default_configuration 
		freeze_channel_list
	end
	def run
		game.start
		views.each { |v| v.setup }
		views.each { |v| v.render }
		while 1
			status = game.run_once
			break unless status
			views.each { |v| v.render }
		end
	ensure
		game.stop
	end
	def register_view(view)
		raise "Error not a view" unless view.is_a? View
		views << view
	end
	def views
		@views ||= []
	end
	def game
		@game
	end
	def register_channel_to(channel,ui)
		raise "Input UI is not a UI it is a #{ui.class}" unless ui.is_a? UI
		raise "Input Channel is not a Chanenl it is a #{channel.class}" unless channel.is_a? Channel
		if valid_channels.has_key? channel.class.name.downcase
			channel.inbound_package= ui.method(:inbound_package)
			ui.request_inbound_package= Tiles::Application::Security.destructive_secure_method(
					channel.method :request_inbound_package 
				)
			channel_instances[ui] = channel
			true
		else
			false
		end
	end

	def register_new_channel_class(string)
		valid_channels[string.to_s.downcase] = true
	end
	private
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

