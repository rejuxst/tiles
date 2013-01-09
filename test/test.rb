require 'pry'
require 'test/unit'
def require_from_source
	$LOAD_PATH << File.absolute_path(File.join(File.dirname(__FILE__),'/../lib/'))
	core = File.join(File.dirname(__FILE__),"..","lib")
	Dir.open(core) do |ent|
		ent.entries.each do |f|
		begin
			succ = gem_original_require File.expand_path File.join(ent.to_path,f.partition('.')[0])
		rescue Exception => e 
			raise <<-EOF
Failed to load file correctly #{File.join(ent.to_path,f.partition('.')[0])} : 
=> #{e}
#{e.backtrace.join("\n")} 
			EOF
		end unless File.directory?(File.join(core,f)) || !(f.match(/\.gitignore/).nil?) || !(f.match(/\.swp/).nil?)
		end 

	end
rescue
	binding.pry
end
class Tiles_Test < Test::Unit::TestCase
	@@test_func = {}
	def non_interactive?
		return true
	end

	def enter_the_test_block
		binding.pry
	end
end
begin
	blkt = File.absolute_path(File.join(File.dirname(__FILE__),'/blocktest/'))
	require_from_source
	ARGV.each do |block|
		puts "================ Testing #{block} ================"
		require blkt +'/'+ block.downcase + "_test.rb"
	end
end
