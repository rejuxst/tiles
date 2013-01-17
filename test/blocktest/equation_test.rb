require 'pry'
class Test_Equation < Tiles_Test
	def test_simple_equation
		temp = Equation.parse("Mp*Health")
		assert_equal(3,temp.length)	
		assert_equal(temp[0],"Mp")	
		assert_equal(temp[1],"*")
	end
end
