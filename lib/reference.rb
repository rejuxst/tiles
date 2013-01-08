require 'database'
class Database::Reference
	@@valid_reference_classes = [String, Class]
	def self.add_valid_reference_class(the_class)
		raise "Not a class #{the_class.class}" if not the_class.is_a? Class
	end
	def initialize(source,chain,is_collection,blk = nil)
		# Input validatino checks
		raise "Source location is not a Database Reference cannot be generated" if !Database.is_database?(source)
		@start = source
		@proc = blk
		@is_collection = is_collection
		chain.each do |ele|
			if !@@valid_reference_classes.any? { |cl| ele.is_a? cl }
				raise "Input Reference chain must contain a valid Reference Object" 
			end
		end unless @is_collection
		if chain.is_a? Array
			@target = []
			chain.each { |ele| @target.push ele }
		else
			@target = chain	
		end
	end
	def validate_target
		if Database.is_database?(@target)
			@target = nil	if !@target.db_alive?
		end
		return @target
	end
	def resolve
		return validate_target if @is_collection
		local = [@start]
		@target.each do |k| 
			return nil if local.any?{|l| !Database.is_database?(l) || !l.db_alive? }
			local = local.collect { |c_db| c_db[k] }; 
		end
		return local.collect { |c_ref| c_ref.resolve } if local.is_a? ::Database::Reference
		return local[0] if local.is_a? Array and local.length == 1
		return local
	end
	def what_died?
		return nil if @is_collection
		local = [@start]
		@target.each do |k| 
			return local if local.any?{|l| !l.db_alive? }
			local = local.collect { |c_db| c_db[k].resolve }; 
		end
		return local.collect { |c_ref| c_ref.what_died? } if local.is_a? ::Database::Reference
		return nil
	end
end
