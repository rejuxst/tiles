require 'pry'
require 'polyglot'
require 'treetop'

class Test_EventHandler < Test::Unit::TestCase
	Tiles::Application::Configuration.use_default_configuration rescue nil
	def test_interactive
		a = ::Tiles::Application::EventHandler.new
		b = Event.new(:blk => Proc.new { puts "Event Completed" })
		a.enqueue :event => b, :at => :now
		#binding.pry
	rescue
		binding.pry
	end
	def test_interactive
		$TEST_VAR = 0
		a = ::Tiles::Application::EventHandler.new
		b = Event.new :blk => Proc.new { $TEST_VAR = $TEST_VAR + 1 }
		a.enqueue :event => b, :at => :now
		a.run :until => :now
		assert_equal(1,$TEST_VAR, "Enqueued event didnt occur" )
		a.run :until => :now
		assert_equal(1,$TEST_VAR, "Enqueued event didnt occur the first time or occured more than once" )
	end
end
