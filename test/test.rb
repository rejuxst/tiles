require 'pry'
class Test
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
	def self.run_test
		it = self.new
		puts "================ Testing using #{it.class} ================"
		puts "================ Finished Testing          ================"
	end
end
begin
	blkt = File.absolute_path(File.join(File.dirname(__FILE__),'/blocktest/'))
	ARGV.each do |block|
		load blkt +'/'+ block.downcase + "_test.rb"
		eval('Test::' + block + '.run_test')
	end
end
