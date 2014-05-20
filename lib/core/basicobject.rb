class Tiles::BasicObject 
	include Database::Data
	include Database::Base
	extend Database::Data
	extend Database::Base
	include Generic::Base
	extend Generic::Base::Extentions	

	::Tiles::Application::ObjectSpace.register_basicobject_class(self)

	def self.inherited(base)
		::Tiles::Application::ObjectSpace.register_basicobject_class(base)
		base.init_database
	end

	def self.new(*args)
		::Tiles::Application::ObjectSpace.register_instance(super(*args))
	end
end
