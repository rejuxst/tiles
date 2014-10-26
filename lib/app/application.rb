# Tiles::Application class:
# - Container for an executable tiles instance
# - Only object that can own (be the parent of) a object without being part of the tiles Database system
# - Contains:
#   -- The Main Object (Generally a game possibly a UI or Something if the game hasn't been generated)
#  -- The Application Event Handler: Any Application level events
#  -- List of Views: Accessors to the remote/local views for rendering purposes
#  -- List of Channels: Usually associated with the views 
# -


class Tiles::Application
  # Secure the Application class
  private :method
  private :send 
  private	:singleton_class
  private :singleton_method_removed
  private	:singleton_method_added
  #################################


  def initialize(opts = {},&blk)
  	opts[:valid_channels].each { |ch| register_new_channel_class ch } if (opts[:valid_channels] || "").is_a? Array
  	@game = opts[:game]
  	yield @game,self if block_given?
  	@configuration= Tiles::Application::Configuration.last_config || 
  			Tiles::Application::Configuration.use_default_configuration 
  	freeze_channel_list
  end

  def run
  	# Setup
  	game.start
  	views.each { |v| v.setup }
  	views.each { |v| v.render }
  	# Execution loop
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
  	raise "Input Channel is not a Channel it is a #{channel.class}" unless channel.is_a? Channel
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
require 'app/security'
