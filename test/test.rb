#!/usr/bin/env ruby
require 'optparse'
require 'pry'
def require_from_source
	require 'polyglot'
	require 'treetop'
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
def require_test_library
	require 'test/unit'
end
begin
	require_from_source
	blkt = File.absolute_path(File.join(File.dirname(__FILE__),'/blocktest/'))
	op = OptionParser.new do |opts|
	  opts.banner = "Usage: test/test.rb [class_name(s)] [options]"

	  opts.order do |arg| 
		binding.pry
		require_test_library
		puts "================ Testing #{arg} ================"
		require File.join(blkt,arg.downcase) + "_test.rb" 
	  end

	  opts.on("-l", "--list","List known test blocks") do |v|  
			puts "Avalible Test Units: "
			Dir.open(blkt).entries.each { |e| puts "\t#{e}" if e.match /\.rb/} 
	  end 


	  opts.on("-a", "--all", "Test all blocks") do |v|
		require_test_library
		Dir.open(blkt).entries.each do |e| 
			begin
				 require File.join(blkt,e) 
				 puts "Test::Unit::TestCase ===> #{e}"
			rescue LoadError
			end
		end 
	  end
	  opts.on("-o","--look-test","Open the test file using default editor") do
		ARGV.each do |b| 
			if File.exists? File.join(blkt,b.downcase + "_test.rb")
				system("echo /usr/bin/env $EDITOR #{File.join(blkt,b.downcase + "_test.rb")}") 
				system("/usr/bin/env $EDITOR #{File.join(blkt,b.downcase + "_test.rb")}") 
			else
				puts "File doesn't exist => #{File.join(blkt,b.downcase + "_test.rb")}"
			end
		end
		exit
	  end
	  opts.on("-i","--interactive","Load the tiles library and drop into pry") do
		binding.pry
		exit
	  end
	  opts.on("-r","--application","Run /testapp/main application") do
		load File.join(blkt,'..','testapp','main.rb')
		exit
	  end


	end
	(ARGV.empty?) ? puts(op.banner) : op.parse!
	Kernel.puts "Testing on: #{RUBY_ENGINE}@#{RUBY_VERSION}"
	ARGV.each do |block|
		require_test_library
		puts "Test::Unit::TestCase ===> #{block}"
		require blkt +'/'+ block.downcase + "_test.rb"
	end


end
