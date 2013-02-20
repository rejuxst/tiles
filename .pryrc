Pry.config.commands.command "dt", "Executes the given block in the current context. Outputs the execution time." do |bind|
	blk = eval("Proc.new { " + arg_string + "}")
	cc = eval('self',target)
	t1 = Time.now
	o = cc.instance_exec &blk 
	t2 = Time.now
	puts "dt :: #{1000.0 * (t2 - t1)} ms"
	puts "=> #{o}"
end
