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
