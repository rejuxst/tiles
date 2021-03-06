require 'pry'
class Test_Equation < Test::Unit::TestCase
	Tiles::Application::Configuration.use_default_configuration rescue nil # Standardized use of Database requires this config call
	def test_simple_equations		
		assert_equal 3	,Equation.new('2+1').resolve	
		assert_equal 3	,Equation.new('(2+1)').resolve	
		assert_equal 5	,Equation.new(' 4 + 1').resolve
		assert_equal 21	,Equation.new(' 4*5 + 1').resolve
		assert_equal 21	,Equation.new(' 4 *5 + 1').resolve
		assert_equal 19	,Equation.new(' 4 *5 + -1 ').resolve
	end
	def test_bad_equations
		assert_not_nil Equation.new('21+') 
		assert_not_nil Equation.new(' 21)')
		assert_not_nil Equation.new('- 21')
		assert_not_nil Equation.new('- 2 + 1* 3-')
	end
	def test_variable
		# Test Object
		thing = Thing.new # Thing is used in this context primaryly because it is a Database and a Generic
		thing.add_reference "item", Thing.new , :add_then_reference => true
		thing.item.add_variable "value", 0
		eq = Equation.new("value + 2")
		assert eq.parse_failure? , "Equation did not resolve => #{Equation.last_failure_reason}"
		eq.source = thing.item
		assert_equal 2, eq.resolve
		thing.item.value.set 3
		assert_equal 5, eq.resolve
		thing.item.add_variable "output", 0
		# Test Resolving to targets value
		eq = Equation.new("output = value + 2")
		assert eq.parse_failure? , "Equation did not resolve => #{Equation.last_failure_reason}"
		eq.source = thing.item
		eq.resolve
		assert_equal 5, thing.item.output
		# Test nested variables
		eq = Equation.new("item#output = item#value + 2")
		assert eq.parse_failure? , "Equation did not resolve => #{Equation.last_failure_reason}"
		eq.source = thing
		eq.resolve
		assert_equal 5, thing.item.output
		# Test defaulting
		eq = Equation.new("item#output = item#nonexist?4 + 2")
		eq.source = thing
		eq.resolve
		assert_equal 6, thing.item.output
	end
end
