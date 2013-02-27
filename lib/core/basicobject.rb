class Tiles::BasicObject 
	include Generic::Base
	::Tiles::Application::ObjectSpace.register_basicobject_class(self)
	def self.inherited(base)
		::Tiles::Application::ObjectSpace.register_basicobject_class(base)
	end
	def self.new(*args)
		::Tiles::Application::ObjectSpace.register_instance(super(*args))
	end
end
