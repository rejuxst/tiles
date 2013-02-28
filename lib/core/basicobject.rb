class Tiles::BasicObject 
	include Database
	extend  Database
	include Generic::Base
	extend Generic::Base::Extentions	

	::Tiles::Application::ObjectSpace.register_basicobject_class(self)

	def self.inherited(base)
		::Tiles::Application::ObjectSpace.register_basicobject_class(base)
	end
	def self.new(*args)
		::Tiles::Application::ObjectSpace.register_instance(super(*args))
	end
end
