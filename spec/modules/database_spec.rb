require 'spec_helper'
describe Database do
	let :module_instance do
		@module_instance_class ||=
			Class.new(Object) do
				include Database::Data
				include Database::Base
				def inspect    ; "#<#{self.class}:#{object_id}>" ; end
				def initialize ; init_database ; end
				def uuid       ; self.inspect ; end
			end
	end

	let :l3_db_array do
		add_list = [module_instance.new]
		add_module_to = lambda { |i| i.add_to_db add_list.push(module_instance.new).last }
		modified = 0
		## Create a 3 level tree
		3.times do
			(modified...(modified = add_list.size)).each do |i|
				2.times { add_module_to.call(add_list[i])  }
			end
		end
  	add_list
	end

	it 'should correctly add an element' do
		root = module_instance.new
		root.add_to_db node = module_instance.new
		expect(root.db.each_value.to_a - [node]).to be_empty
	end

	it 'should correctly add a element into a tree' do
		add_list = [module_instance.new]
		add_module_to = lambda { |i| i.add_to_db add_list.push(module_instance.new).last }

		modified = 0
		## Create a 3 level tree
		3.times do
			(modified...(modified = add_list.size)).each do |i|
				2.times { add_module_to.call(add_list[i])  }
			end
		end

		expect(add_list.size).to eq(15) ## 1(root) + 2 + 4 + 8 = 15
		## get all the nodes from the tree
		elements_in_tree =
			add_list.size.times.inject([add_list.first]) do |res, _|
				res + res.collect { |e| e.db.each_value.to_a }.flatten(1)
			end.uniq(&:uuid)

		expect(elements_in_tree.size).to eq(add_list.size)
		expect(elements_in_tree - add_list).to be_empty
  end
	describe '#destroy_self' do
		it 'should not be alive after removal' do
			(node = module_instance.new).destroy_self
			expect(node.db_alive?).to be(false)
		end

		it 'should remove a leaf node in a tree' do
			l3_db_array[7].destroy_self
			expect(l3_db_array[7].db_alive?).to be(false), "failed leaf node destruction"
			expect(l3_db_array.select(&:db_alive?).size).to eq(14)
		end

		it 'should delete a branch if branch root is destroyed' do
			l3_db_array[4].destroy_self
			expect(l3_db_array.select(&:db_alive?).size).to eq(12)
			[l3_db_array[4], *l3_db_array[4].db.each_value.to_a].each do |node|
				expect(node.db_alive?).to be(false), "failed node destruction"
			end
		end

		it 'should recursively delete a branch if the large branch root is destroyed' do
			l3_db_array[0].destroy_self
			expect(l3_db_array.select(&:db_alive?).size).to eq(0),
				"Some nodes are still alive after deletion"
		end
	end

	describe Database::Reference do
		let(:root) { module_instance.new }
		let(:node) { root.add_to_db(item = module_instance.new) ; item }
		it 'should allow local references' do
			root.add_reference("node", node)
			expect(root["node"]).to equal(node)
		end
		it 'should account for dead references' do
			root.add_reference("node", node)
			node.destroy_self
			expect(root["node"]).to be_nil
	  end
  end

end
