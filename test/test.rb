require 'pry'
def require_from_source
	$LOAD_PATH << File.absolute_path(File.join(File.dirname(__FILE__),'/../lib/'))
	core = File.join(File.dirname(__FILE__),"..","lib")
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
class Test
	@@test_func = {}
	def self.register_test(*args)
		args.each { |x| raise "register_test only accepts symbols" unless x.class <= Symbol }
		@@test_func["#{self}"] = [] if @@test_func["#{self}"].nil?
		args.each { |x| @@test_func["#{self}"] << x }	
	end
	def non_interactive?
		return true
	end

	def enter_the_test_block
		binding.pry
	end
	def self.run_test
		it = self.new
		puts "================ Testing using #{it.class} ================"
		@@test_func["#{self}"].each do |x|
			it.send(x)	
		end if !@@test_func["#{self}"].nil?
		puts "================ Finished Testing          ================"
		unless it.non_interactive?
			it.enter_the_test_block
		end
	rescue
		binding.pry
	end
end
begin
	blkt = File.absolute_path(File.join(File.dirname(__FILE__),'/blocktest/'))
	require_from_source
	ARGV.each do |block|
		load blkt +'/'+ block.downcase + "_test.rb"
		eval('Test_' + block + '.run_test')
	end
end
