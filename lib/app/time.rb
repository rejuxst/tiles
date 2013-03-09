class Tiles::Time
	include Comparable
	def initialize(obj = nil)
		@value = obj
	end
	def hash
		raw_value.hash
	end
	def raw_value
		@value
	end
	def <=>(other)
		raw_value <=> _get_raw_value(other)
	end
	def ==(other)
		raw_value == _get_raw_value(other)
	end
	def ===(other)
		raw_value === other.send(self.class.downcase.to_sym)
	end
	private
	def _get_raw_value(other)
		if responds_to? :raw_value
			other.raw_value
		else
			other
		end
	end
end
