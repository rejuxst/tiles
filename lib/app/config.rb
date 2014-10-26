class Tiles::Application::Configuration
  private_class_method :new
  def self.new_configuration(opts = {},&blk)
  	@last_config = new(opts)
  	(block_given?)?(yield (@last_config.access)):(blk || Proc.new {}).call(@last_config.access)
  	last_config
  end
  def self.use_default_configuration
  	new_configuration
  	last_config.set_configuration
  	last_config
  end
  def self.lock_configuration
  	@last_config.lock
  end
  def self.last_config
  	@last_config
  end
  def self.add_default_configuration_call(m_or_c,meth,*inputs,&blk)
  	str =  <<-EOF
  	lambda do |#{input_parameters(m_or_c,meth)}| 
  		#{m_or_c.name}.#{meth.to_s}(#{input_parameters(m_or_c,meth)})
  	end
  	EOF
  	(@@default_conf ||= []).push (inputs << (blk || [])) + [eval(str)]  
  	str
  end
  def self.add_configuration_method(m_or_c,meth)
  	str =  <<-EOF
  		def #{m_or_c.name.downcase}_#{meth.to_s}(#{input_parameters(m_or_c,meth)})
  			(@configure ||= []).push [#{input_parameters(m_or_c,meth).delete('&')}] + [
  			lambda do |#{input_parameters(m_or_c,meth)}| 
  				#{m_or_c.name}.#{meth.to_s}(
  					#{input_parameters(m_or_c,meth)}
  				)
  			end
  			]
  		end
  	EOF
  	class_eval str
  	configuration_list[m_or_c] = (configuration_list[m_or_c] || []) + [meth]
  	str
  end
  private
  def self.configuration_list
  	@@configuration_list ||= {}
  end
  def configuration_list
  	@@configuration_list ||= {}
  end
  def self.input_parameters(m_or_c,meth)
  	(
  		["*inputs"] + (m_or_c.method meth.to_sym).parameters.collect do |param|
  			case param[0]
  				when :block then "&#{param[1].to_s}"
  				else nil
  			end
  		end.delete_if { |e| e == nil }
  	).join(',')
  end
  public
  def initialize(opts)		
  	@configure = @@default_conf.collect {|c| c} unless opts[:empty_configuration]
  	
  end	
  def lock
  	freeze
  end
  def access
  	self unless frozen?
  end
  def set_configuration
  	(@configure ||= []).each do |arr| 
  		meth = arr.pop
  		if arr.last.is_a?(Proc) 
  			blk = arr.pop
  			 meth.call(*arr,&blk)  
  		else
  			 meth.call(*arr)
  		end
  	end
  ensure
  	@configure = [] #NOTE: Not sure if the configuration should be deleted after use (
  			#	right now deleteing because we dont want to call on accident
  			# 	)
  end
  
end
module Tiles::Configurable
  def configuration_method(*method_list)
  	opts = method_list.pop if method_list.last.is_a? Hash
  	method_list.each do |meth| 
  		raise "Attempting to add method #{meth} to configuration list 
  		failed not a valid method name (valid_name? => #{valid_method_name?(meth)}) 
  		or doesn't respond to the method 
  		(#{self}#respond_to? => #{self.respond_to?(meth.to_sym)})
  		".delete("\t\n") unless valid_method_name?(meth) && self.respond_to?(meth.to_sym)
  		Tiles::Application::Configuration.add_configuration_method(self,meth.to_sym) 
  	end
  end
  def valid_method_name?(meth)
  	meth.to_sym.is_a? Symbol
  end 
  def default_configuration_call(meth,*inputs,&blk)
  	if blk
  	Tiles::Application::Configuration
  		.add_default_configuration_call(self,meth.to_sym,*inputs,&blk)
  	else
  	Tiles::Application::Configuration
  		.add_default_configuration_call(self,meth.to_sym,*inputs)
  	end
  end

end
