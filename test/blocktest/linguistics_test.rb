require 'pry'
require 'polyglot'
require 'treetop'
require 'treetop/linguisticsparser.treetop'
require 'lang/english'
require 'lang/englishparser'
class Test_Linguistics < Tiles_Test
	#assert_nothing_raised("Parser failed to load") { ::Linguistics.parser= ::LinguisticsParser.new }
	::Linguistics.parser= ::LinguisticsParser.new 
	def test_equation_syntax
		# These Should compile without failure
		["A+", "{A+}", "A+ or B-", "A+ & B-", "Q+ or ()", "R+    or (R+)", "((()))"].each do |str|
			assert_not_nil ::Linguistics.parse(str) , "#{str} => #{::Linguistics.parser.failure_reason}"
		end
		# These Should not compile
		["A", "{A+", "A+B-", "& B-"," ( or", "()))("].each do |str|
			assert_nil ::Linguistics.parse(str) , "#{str} => \n#{::Linguistics.parse(str).inspect}"
		end
	end
	def test_connector_list
		a =::Linguistics.parse "A+ & B- & C-"
		b = ::Linguistics.parse "(A+ or Q+) & B- & C-"
		assert_equal(3,a.list_connectors.length)
		assert_equal(4,b.list_connectors.length)
	end 
	def test_interactive
		binding.pry
	end
end
