require 'pry'
class Test_Equation < Tiles_Test
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
		thing = Thing.new
		thing.add_reference "item", Thing.new , :add_then_reference => true
		thing.item.add_variable "value", 0
		eq = Equation.new("value + 2")
		assert eq.parse_failure? , "Equation did not resolve => #{Equation.last_failure_reason}"
		eq.source = thing.item
		assert_equal 2, eq.resolve
		thing.item.value.set 3
		assert_equal 5, eq.resolve
		thing.item.add_variable "output", 0
		eq = Equation.new("output = value + 2")
		assert eq.parse_failure? , "Equation did not resolve => #{Equation.last_failure_reason}"
		eq.source = thing.item
		eq.resolve
		assert_equal 5, thing.item.output
		eq = Equation.new("item#output = item#value + 2")
		assert eq.parse_failure? , "Equation did not resolve => #{Equation.last_failure_reason}"
		eq.source = thing
		eq.resolve
		assert_equal 5, thing.item.output
	end
end
