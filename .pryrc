begin
	Pry.commands.alias_command 'c', 'continue'
	Pry.commands.alias_command 's', 'step'
	Pry.commands.alias_command 'n', 'next'
	Pry.commands.alias_command 'f', 'finish'
rescue 
	nil
end
Pry.config.commands.command "dt", "Executes the given block in the current context. Outputs the execution time." do |bind|
	#blk = eval("Proc.new { " + arg_string + "}")
	#cc = eval('self',target)
	t1 = Time.now
	o = eval(arg_string,target)
	#o = cc.instance_exec &blk 
	t2 = Time.now
	puts "dt :: #{1000.0 * (t2 - t1)} ms"
	puts "=> #{o}"
end
Pry::Commands.import Pry::CommandSet.new do
  block_command "greet" do |name|
    output.puts "hello #{name}"
  end

  block_command "add5" do |num|
    output.puts "#{num.to_i + 5}"
  end
end
