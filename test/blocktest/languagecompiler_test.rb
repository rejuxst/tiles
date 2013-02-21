require 'treetop/linguisticsparser.treetop'
require 'lang/english'
require 'lang/englishparser'
require 'treetop/compiler.treetop' #NOTE: must include with .treetop ext as treetop/compiler is a folder in the treetop gem

class Test_LanguageCompiler < Test::Unit::TestCase
	Tiles::Application::Configuration.use_default_configuration rescue nil
	::Linguistics.parser= ::LinguisticsParser.new 
	#Treetop.load File.join(File.dirname(__FILE__),"..","..","lib","treetop")
  def test_interactive
	assert_not_nil a = LanguageCompiler.parse( ' $TERMINAL_CHARACTERS : /lmn/ ; ' )
	assert_not_nil b = LanguageCompiler.parse(
				'@var : A+;
				% Comment
				@bar : B+;
				$TERMINAL_CHARACTERS : /[\s_";()]/ ;
				'
			), LanguageCompiler.failure_reason
	assert_not_nil dict1 = LanguageCompiler.parse( 
					'water anger money politics trouble: {@A-} & {Dmu-} & 
					{@M+ or (R+ & Bs+)} & (J- or Os- or (Ss+ & (({@CO-} & {C-}) or R-)) or SIs-);' 
				)
	assert_not_nil dict0 = LanguageCompiler.parse(
     				'
    				 I    : J- or O- or (Sp+ & (({@CO-} & {C-}) or R-)) or SIp-;
    				 ran  : {@E-} & (S- or (RS- & B-)) & {@MV+};
     				 with : J+ & (Mp- or MV- or Pp-);
    				 the  : D+;
     				 dog  : {@A-} & Ds- & {@M+ or (R+ & Bs+)} & (J- or Os- or (Ss+ & (({@CO-} & {C-}) or R-)) or SIs-);
     				'
    			), LanguageCompiler.failure_reason
	assert_not_nil dict2 = LanguageCompiler.parse(
<<EOF
")" "%" "," "." ":" ";" "?" "!" "''" "'" "'s" "'re" "'ve" "'d" "'ll" "'m" : RP-;
"(" "$" "``" : LP-;
<CLAUSE>: {({@COd-} & C-) or ({@CO-} & (Wd- & {CC+})) or [Rn-]};
EOF
    			), LanguageCompiler.failure_reason
	LanguageCompiler.generate_instance_dictionary English, dict0
	a = English.parse "I ran with the dog"
	assert_not_equal :failed,a.parse, "Link parse failed on => #{a.text_value}"
  end
end
