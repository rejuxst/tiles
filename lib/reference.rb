require 'pry'
require 'database'
class Database::Reference
	@@valid_reference_classes = [String, Class]
	def self.add_valid_reference_class(the_class)
		raise "Not a class #{the_class.class}" if not the_class.is_a? Class
	end
	def self.is_valid_reference_class(the_class)
		@@valid_reference_classes.any? {|cl| cl == the_class}
	end

	def what_died?
		return @source if not @source.db_alive? 
		return @target if resolve.nil?
		return nil
	end
	def initialize(source,target)
                # Input validation checks
		raise "Source location is not a Database Reference cannot be generated" if !Database.is_database?(source)
		raise "Target location is not a Database Try making a local reference" if !Database.is_database?(source)
                @source = source
		@target = target
	end
	def resolve
		return @target if @target.db_alive? and @source.db_alive?
		return nil
	end
	class Chain < ::Database::Reference
		def initialize(source,target_chain)
		raise "Source location is not a Database Reference cannot be generated" if !Database.is_database?(source)
			target_chain = [target_chain] if not target_chain.is_a? Array
			@source = source
			@target_chain = target_chain
			unless @target_chain.all? {|element| Database.is_database_entry_class?(element.class)}
				raise "Invalid Reference::Chain element in chain #{@target_chain}"
			end
			#raise "Unable to resolveto non-nil object on first try" if resolve().nil?
		end
		def resolve
			local_varible = [@source]
			@target_chain.each do |ele| 
				next_varible = []
				local_varible.each{|var| next_varible << var[ele] unless var.nil? }
				local_varible = next_varible
			end
			return (local_varible.length < 2) ? local_varible[0] : local_varible
		end
	end
	class Collection < ::Database::Reference
	end
end




