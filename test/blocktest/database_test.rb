require 'pry'
#require 'test/unit'
class Test_Database < Test::Unit::TestCase
	Tiles::Application::Configuration.use_default_configuration
	attr_accessor :t3
	def non_interactive?
		return true
	end
	
	# Generates basic *Database* tree of depth 3 using test class TDB
	def tree3
		g = TDB.new
		2.times { g.add_to_db(TDB.new) }
		g.for_each_db_entry { |e| 2.times { e.add_to_db(TDB.new) } }
		g.for_each_db_entry do |e|
			e.for_each_db_entry { |f| 2.times { f.add_to_db(TDB.new) } }
		end
		return g
	rescue
		binding.pry unless non_interactive?
	end
	
	# Printing support function for testing Database suggested use with non_interactive? set false
	def print_tree(tree,tablvl = 0)
		puts "=" + ">" * tablvl + "#{tree.key} = #{tree.db_alive? ? "alive" : "dead"}"
		tree.for_each_instance { |e| print_tree(e,tablvl+1)}
		return nil
	end

	# Test add_to_db by checking the size of the depth 3 tree
	def test_add
		t3 = tree3
		list = []
		list << t3
		begin
			t3.for_each_db_entry { |e| list << e }
			t3.for_each_db_entry { |e| e.for_each_db_entry { |f| list << f} }
			t3.for_each_db_entry { |e| e.for_each_db_entry { |f|   f.for_each_db_entry { |g| list << g} } }
		end rescue assert(false, "Failed to correctly generate tree list") and return false
		# Size check: add_to_db works
		assert_equal(15,list.length, "Expected 15 elements in the Tree")
		return list
	end

	# Removes element from a tree. Testing destructive/status functions: 
	#	destroy_self (and its recursive implementation), db_alive? 
	def test_remove
		list = test_add
		list[7].destroy_self
		sum = 0
		list.each { |l| sum = sum +1 if l.db_alive? } 
		assert(!list[7].db_alive? && sum == 14 , "Failed on Destruction of a Database Leaf node")
		# Singluar Destruction: Destroy a branch
		list[4].destroy_self
		sum = 0
		list.each { |l| sum = sum +1 if l.db_alive? } 
		first_test = !list[7].db_alive? && sum == 11 && !list[4].db_alive? && !list[9].db_alive? && !list[10].db_alive?
		assert(first_test , "Failed to correctly destroy a branch" )
		# Singluar Destruction: Destroy a nested branch
		list[2].destroy_self
		sum = 0
		list.each { |l| sum = sum +1 if l.db_alive? } 
		large_pass = [4,5,6,7,9,10,11,12,13,14].all?{ |n| !list[n].db_alive?} && sum == 4
		assert(large_pass, "Large Branch Deletion Failed")
	rescue
		binding.pry
	end
	
	# Support function for testing parent child interaction of a database
	def valid_parent_child(par,chd)
		assert(chd.db_parent == par && par[chd.key] == chd && par.find_key(chd) == chd.key, "Invalid Database Parent Child Relationship" )
	end

	# Test tree connectivity tests functions: parent, key
	def test_valid_tree
		rec_valid_tree tree3()
	end

	# Recursive function for test_valid_tree
	def rec_valid_tree(tree)
		valid = true
		tree.for_each_instance do |x| 
			valid_parent_child(tree,x)
			rec_valid_tree(x) 
		end
		return valid
	end
	
	# Test Reference implementation NOTE: this assumes default_configuration
	def test_add_basic_reference
		base = TDB.new
		element = TDB.new
		base.add_to_db(element) # element is now a child of base
		base.add_reference("element",element) 	# We can assign a reference to "element"
							# NOTE: As of now there is no need to add_to_db
							# to call this function correctly
		assert_same(element,base["element"], "Unable to Sucessfully Dereference a generated Local Reference")
	end

	# Test to validate reference death on death of child node if element is dead base["element"] should be dead
	def test_dead_basic_reference
		base = TDB.new
		element = TDB.new
		base.add_to_db(element)
		base.add_reference("element",element)
		element.destroy_self
		assert_nil(base["element"], "This should be Nil as the Database has been killed")
	end


	# Test chain reference I should be able to reference weapon as element#db_parent#object#weapon
	# If any object in the seqeunce died the reference should die. This test checks successful generation
	def test_reference_of_reference
		base = TDB.new
		element = TDB.new
		object = TDB.new
		weapon = TDB.new
		base.add_to_db element
		base.add_to_db object
		object.add_to_db weapon
		element.add_reference("db_parent",element.db_parent)
		base.add_reference("object",object)
		object.add_reference("weapon",weapon)
		element.add_reference_chain("double",["db_parent", "object", "weapon"])
		assert_same(element["double"],weapon, "Reference of Reference does not work")	
	end
	
	# Test destruction of a reference when an object in the reference chain dies
	def test_dead_reference_of_reference
		base = TDB.new
		element = TDB.new
		object = TDB.new
		weapon = TDB.new
		base.add_to_db element
		base.add_to_db object
		object.add_to_db weapon
		element.add_reference("db_parent",element.db_parent)
		base.add_reference("object",object)
		object.add_reference("weapon",weapon)
		object.destroy_self
		element.add_reference_chain("double",["db_parent", "object", "weapon"])
		assert_nil(element["double"], "Reference of Reference should have died")	
		assert(element["db_parent"].db_alive?, "This Reference should not have died")	
	end

	###########
	# Test class for interacting with Database instances
	class TDB 
		include ::Database::Data
		include ::Database::Base
		def initialize()
			init_database
		end
		def inspect
			"#<#{self.class}:#{object_id}>"
		end

	end
end
