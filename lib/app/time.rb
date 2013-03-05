module Tiles::Time::Generator < BasicObject
	def self.generate_timespace(opts = {})
		# "%s %w %q" => [:days, :weeks, :years] (Definition of to String from string format)
		# Symbol => String/Proc   (define the function Symbol that casts the time value using String as a Equation)
		#			ex. :today => { |raw| %w[Monday Tuesday Wendsday Thursday ....][raw % 7] } (block)
		#			ex. :days  => :raw (default reference)
		#			ex. :months => "raw % 30" (Equation)
		# :valid_units	=> Array  (of the listed Symbols that themselves are valid units)
		#				This allows for "dimensional analysis" i.e "years = date - month - day"
	end
end
