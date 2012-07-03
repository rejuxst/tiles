require "active"
require "thing"
require 'database'
class Actor < Thing
	include Active
	include Database	
	
end
