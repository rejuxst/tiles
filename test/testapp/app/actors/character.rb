class Character < Actor
	add_properties :hp
end
class Hp < Property
	requires_value "max_hp", Fixnum
	requires_value "hp", Fixnum
	requires_variable_alias "hp" , "hp"
	requires_variable_alias "max_hp" , "max_hp"
	def init(*args)	
		self.max_hp.set 10
		self.hp.set self.max_hp
	end
end
