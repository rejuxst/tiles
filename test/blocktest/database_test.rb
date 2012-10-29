require 'pry'

def non_interactive?
	return true
end
def require_from_source
	$LOAD_PATH << File.absolute_path(File.join(File.dirname(__FILE__),'/../../lib/'))
	core = File.join(File.dirname(__FILE__),"..","..","lib")
	#puts "$LOAD_PATH LIST:"
	#puts $LOAD_PATH
	Dir.open(core) do |ent|
		ent.entries.each do |f|
		unless File.directory?(File.join(core,f)) || !(f.match(/\.gitignore/).nil?) || !(f.match(/\.swp/).nil?)
			succ = gem_original_require File.expand_path File.join(ent.to_path,f.partition('.')[0])
		end
		end
	end
rescue
        binding.pry
end
def create_global_database
	$global_db = TDB.new
	$all_things = [$global_db]
end
def create_global(a)
	$all_things << a
	global_add_to_db(a)
end
def global_add_to_db(a)
	$global_db.add_to_db(a)
end
def global_remove_from_db(a)
	$global_db.remove_from_db(a)
end
def global_destroy(a)
	$global_db.destroy_entry(a)
end
def tree3
	g = TDB.new
	2.times { g.add_to_db(TDB.new) }
	g.for_each_db_entry { |e| 2.times { e.add_to_db(TDB.new) } }
	g.for_each_db_entry do |e|
		e.for_each_db_entry { |f| 2.times { f.add_to_db(TDB.new) } }
	end
	return g
rescue
	binding.pry
end
def print_tree(tree,tablvl = 0)
	puts "=" + ">" * tablvl + "#{tree.key} = #{tree.db_alive ? "alive" : "dead"}"
	tree.for_each_instance { |e| print_tree(e,tablvl+1)}
	return nil
end
def test_add_remove
	puts "Testing add_to_db and remove_from_db"
	t3 = tree3
	list = []
	list << t3
	t3.for_each_db_entry { |e| list << e }
	t3.for_each_db_entry { |e| e.for_each_db_entry { |f| list << f} }
	t3.for_each_db_entry { |e| e.for_each_db_entry { |f|   f.for_each_db_entry { |g| list << g} } }
	# Size check: add_to_db works
	if(list.length == 15)
		puts "\tCorrect number of elements in a binary tree depth 3 (which is 15): pass"
	else
		raise "Incorrect number of element in binary tree of depth 3 #{list.length}: fail"
	end
	# Singular destruction: destroy_self on leaf Database works
	list[7].destroy_self
	sum = 0
	list.each { |l| sum = sum +1 if l.db_alive } 
	puts "\tTesting singular delete: #{(!list[7].db_alive && sum == 14) ? "pass" : "fail" }"
	# Singluar Destruction: Destroy a branch
	list[4].destroy_self
	sum = 0
	list.each { |l| sum = sum +1 if l.db_alive } 
	puts "\tTesting branch delete: #{(!list[7].db_alive && sum == 11 && !list[4].db_alive && !list[9].db_alive && !list[10].db_alive) ? "pass" : "fail" }"
	# Singluar Destruction: Destroy a nested branch
	list[2].destroy_self
	sum = 0
	list.each { |l| sum = sum +1 if l.db_alive } 
	large_pass = sum == 4 && !list[7].db_alive && !list[4].db_alive && !list[9].db_alive && !list[10].db_alive &&  !list[5].db_alive 
	large_pass = large_pass && !list[6].db_alive &&  !list[11].db_alive &&  !list[12].db_alive && !list[13].db_alive && !list[14].db_alive
	puts "\tTesting large branch delete: #{(large_pass)? "pass" : "fail" }"
rescue
	binding.pry
end
def valid_parent_child(par,chd)
	return (chd.db_parent == par && par[chd.key] == chd && par.find_key(chd) == chd.key)? true : false
end
def test_valid_tree
	puts "Test if Tree depth 3 is a valid databse tree: #{(rec_test_valid_tree(tree3()))? "pass": "fail" }"
end
def rec_test_valid_tree(tree)
	valid = true
	tree.for_each_instance do |x| 
		valid = valid && valid_parent_child(tree,x)
		valid = valid && rec_test_valid_tree(x) 
	end
	return valid
end
###########
require_from_source    # Load the Tiles Core (Syntax Test Bench)
class TDB 
	include Database
	def initialize()
		init_database
	end
end
begin
	#create_global_database
	#5.times {|x| create_global(TDB.new) }
	puts "============ Testing Database module ====================="
	test_valid_tree
	test_add_remove
	puts "============ Finished Testing ====================="
	unless non_interactive? # Alias global to local
		binding.pry
	end
rescue
	binding.pry
end

