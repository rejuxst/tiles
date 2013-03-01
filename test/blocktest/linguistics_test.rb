require 'pry'
require 'polyglot'
require 'treetop'
require 'lang/language.rb'
require 'grammars/linguisticsparser.treetop'
require 'lang/en/english'
require 'lang/en/englishparser'
class Test_Linguistics < Test::Unit::TestCase
	Tiles::Application::Configuration.use_default_configuration rescue nil
	::Linguistics.parser= ::LinguisticsParser.new 
	def test_equation_syntax
		# These Should compile without failure
		["A+", "{A+}", "A+ or B-", "A+ & B-", 
		 "Q+ or ()", "R+    or (R+)", "((()))",
		"(A+ or B+) & {C- & (D+ or E-)} & {@F+}"
		].each do |str|
			assert_not_nil ::Linguistics.parse(str) , 
				"#{str} => #{::Linguistics.parser.failure_reason}"
		end
		# These Should not compile
		["A", "{A+", "A+B-", "& B-"," ( or", "()))("].each do |str|
			assert_nil ::Linguistics.parse(str) , 
				"#{str} => \n#{::Linguistics.parse(str).inspect}"
		end
	end



	def test_connector_list
		a =::Linguistics.parse "A+ & B- & C-"
		b = ::Linguistics.parse "(A+ or Q+) & B- & C-"
		assert_equal(3,a.list_connectors.length)
		assert_equal(4,b.list_connectors.length)
	end 

	def test_cost
		a =::Linguistics.parse "A+ & B- & C-"
		b =::Linguistics.parse "A+ & [(B- or G+)] & [[C-]]"
		ac = a.list_connectors.sort { |x,y| x.cost <=> y.cost }
		bc = b.list_connectors.sort { |x,y| x.cost <=> y.cost }
		assert_equal 0 , ac[0].cost
		assert_equal 0 , ac[1].cost
		assert_equal 0 , bc[0].cost
		assert_equal 1 , bc[1].cost
		assert_equal 2 , bc[3].cost
	end

	def test_disjunct_list
		a = ::Linguistics.parse "(A+ or B+) & {C- & (D+ or E-)} & {@F+}"
		# We should generate a result from this equation
		assert_not_nil a , "#{a} =>\n #{::Linguistics.parser.failure_reason}"
		# There should be 12 disjuncts in this equation
		assert_equal 12, a.disjuncts.length , "#{a} =>\n Incorrect number of disjuncts"
		# Because priority is important we can expect and demand a specific order to 
		# the set of disjuncts
		assert_equal ["A+","C-","D+","@F+"], a.disjuncts[0].collect { |e| e.text_value } , 
				"#{a} =>\n expected a.disjuncts[0] to be something different"
	end


	def test_connector_syntax
		# Connectors should match the same upper case connector in the opposite
		# direction. All lower case letters should be the same (if one has more lower
		# case letters than the other match up to the lesser number) if there is a *
		# match any lower case letter in that position
		a = (::Linguistics.parse "A+").list_connectors[0]  # Generic connector should match any A- with any lower case letters
		am =(::Linguistics.parse "Am-").list_connectors[0] # Am- : matches A+ Am+ Am*+ A*q+ / doesn't match Aq+ Al+
		aq =(::Linguistics.parse "Aq+").list_connectors[0] # Aq+ : matches A- Aq- A*s-      / doesn't match Al- Am*-
		aarb1 =(::Linguistics.parse "A*s+").list_connectors[0] # A*s+ : matches A- Am- Aq- Ars-  / doesn't match Alq- A*m-
		aarb2 =(::Linguistics.parse "Ams-").list_connectors[0] 
		aarb3 =(::Linguistics.parse "Als-").list_connectors[0]
		assert a.matchs?(am, :forward), 
			"Should have matched A+ to Am-, but didn't"
		assert !aq.matchs?(am, :forward), 
			"Should not have matched Aq+ to Am-, but did"
		assert aarb1.matchs?(aarb2, :forward), 
			"Should have matched A*s+ to Ams-, but didn't"
		assert aarb1.matchs?(aarb3, :forward), 
			"Should have matched A*s+ to Als-, but didn't"
		assert a.matchs?(aarb2, :forward), 
			"Should have matched A*s+ to Ams-, but didn't"
		assert !aarb2.matchs?(aarb3, :forward), 
			"Should not have matched Als- to Ams-, but did"
	end



	def test_single_connection
		# Basic equation testing for single connector example in english
		English::Grammar["adjective"] = "A+"
		English::Grammar["noun"]   = "A-"
		English::Dictionary["large"]  = "adjective"
		English::Dictionary["dog"]    = "noun"
		sen = English.parse 'large dog'
		assert(sen.parse, "Didnt resolve")
		assert_equal('dog',sen.subject.word, "Not the subject")
		assert_equal(['large'],
			sen.subject.adjectives.collect {|adj| adj.word}, 
			"Not the adjective")
	end
end
