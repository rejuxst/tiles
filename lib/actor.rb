require "active"
require "thing"
require 'database'
class Actor < Thing
	include Generic::Base
	include Generic::Responsive
	include Active
end
