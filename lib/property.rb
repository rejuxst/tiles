require "database"
module Property
	class Base
		def initialize(owner)
			@owner = owner
			@value = default()
			@equations = []
		end
		def default
			return 0
		end
		def callback
		end
		def eq_callback
			@equations.each{|e| e.evaluate}
		end
		def self=(value)
			return set(value)
		end
		def set(value)
			@value = value
			callback
			eq_callback
			return @value
		end
		def value
			return @value
		end
		def get
			return @value
		end
		def set_nocallback(value)
			@value = value
			yield self if block_given?
			eq_callback
			return @value
		end
		def set_noeq_callback(value)
			@value = value
			yield self if block_given?
			return @value
		end
		def self.inherited(subclass)
			PropertyDefinition::Tree.add_definition(subclass)
		end
		def add_equation(eq)
			raise "Not a Valid Equation Input" unless eq.is_a? Equation
			return @equations << eq
		end
		def remove_equation(eq)
			return @equations.delete_if {|e| e == eq}
		end
		def remove_all_equations
			@equations.delete
		end
		def destroy
			@equations.each{|e| e.dep_destroyed(self)}
			@equations.delete
			@owner = nil
			@value = nil
		end
		def id
			return Property::Definition::Tree.find_id(self.class)
		end
		def self.id
			return Property::Definition::Tree.find_id(self)
		end
	end
	class Effect
		def self.preform_on(prop,value)
			if block_given?
				return yield
			else
				return prop.set(value)
			end
		end
	end
	class Equation
	# Equations allow the establishment of Property dependancies
	# Equations should be used to associate different properties
		attr_accessor :output, :dependencies, :equation
		def initialize(*args,&blk)
			@output = nil
			@dependencies = []
			@equation = blk
			args.each {|d| add_dependency(d)}
		end
		def self.eval_once(target,&blk)
			return target.set(blk.call) unless target.nil?
			return blk.call
		end
		def evaluate
			return @output = equation.call unless @output.nil?
			return equation.call
		end
		def add_dependency(*prop)
			prop.each do |p| 
				p.add_equation(self)
				@dependencies << p
			end
		end
		def remove_dependency(*prop)
			prop.each do |p| 
				p.remove_equation(self)
				@dependencies.delete_if{|i| i == p}
			end
		end
		def destroy
			yield if block_given?
			@dependencies.each{|d| d.remove_equation(self)}
		end
		def dep_destroyed(dep)
			destroy()	# An Equation that loses a dep should self destruct
		end
	end
	class Group
		def initialize
		
		end
	end
	class Definition
		class Instance
			attr_accessor :iid,:prop
			def initialize(prop)
				raise "Error: Input is not a Property" unless prop.is_a? Property::Base
				@prop = prop
				@iid = Tree.add_instance(self)
			end
			def self.dbentry(prop)
				"<@#{Tree.find_id(prop.class)}|#{@iid}:@#{Database.dbentry_data(prop.value)}>"	
			end
			def destroy
				Tree.remove_instance(self)
				@prop = nil
			end
		end
		class Tree
			@@hash = {}
			def self.add_definition(definition)
				raise "Error: Input is not a Property" unless definition <= Property::Base
				i = 1
				i += 1 while !@@hash[:"id#{i}"].nil?
				@@hash[:"id#{i}"] = definition
				@@hash[:"#{definition}"] = :"id#{i}"
				return :"id#{i}"
			end
			def self.add_instance(inst)
				raise "Error: Input is not a Property" unless inst.is_a? Property::Base
				i = 1
				i += 1 while !@@hash[:"iid#{i}"].nil?
				@@hash[:"iid#{i}"] = inst
				return :"iid#{i}"
			end
			def self.remove_instance(inst)
				@@hash[:"iid#{inst.iid}"] = nil
				return :"iid#{inst.iid}"
			end
			def self.destroy_instance(prop)
			
			end
			def self.find_id(prop)
				return @@hash[:"#{prop}"]
			end
		end
		def self.dbentry(prop)
			return "<&#{Tree.find_id(prop)}:N\"#{prop}\"N^\"#{prop.superclass}\"^#{Database.dbentry_data(prop.value)}&>"
		end
	end
end