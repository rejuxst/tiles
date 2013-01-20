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
end
