#!/usr/bin/env ruby
require 'pry'

## Load aliases for pry stepper
begin
	Pry.commands.alias_command 'c', 'continue'
	Pry.commands.alias_command 's', 'step'
	Pry.commands.alias_command 'n', 'next'
	Pry.commands.alias_command 'f', 'finish'
rescue 
	nil
end

## benchmark tools
Pry.config.commands.command "dt", "Executes the given block in the current context. Outputs the execution time." do |bind|
	t1 = Time.now
	o = eval(arg_string,target)
	t2 = Time.now
	puts "dt :: #{1000.0 * (t2 - t1)} ms"
	puts "=> #{o}"
end
