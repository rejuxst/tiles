require 'treetop/linguisticsparser.treetop'
require 'lang/english'
require 'lang/englishparser'
require 'treetop/compiler.treetop' #NOTE: must include .treetop as treetop/compiler is a folder in the treetop gem

class Test_LanguageCompiler < Test::Unit::TestCase
	Tiles::Application::Configuration.use_default_configuration rescue nil
	::Linguistics.parser= ::LinguisticsParser.new 
	#Treetop.load File.join(File.dirname(__FILE__),"..","..","lib","treetop")
  def test_interactive
	assert_not_nil c = LanguageCompiler.parse(
				'@var : A+
				% Comment
				@bar : B+'
			), LanguageCompiler.failure_reason

	assert_not_nil dict0 = LanguageCompiler.parse(
     				'
    				 I    : J- or O- or (Sp+ & (({@CO-} & {C-}) or R-)) or SIp-;
    				 ran  : {@E-} & (S- or (RS- & B-)) & {@MV+};
     				 with : J+ & (Mp- or MV- or Pp-);
    				 the  : D+;
     				 dog  : {@A-} & Ds- & {@M+ or (R+ & Bs+)} & (J- or Os- or (Ss+ & (({@CO-} & {C-}) or R-)) or SIs-);
     				'
    			), LanguageCompiler.failure_reason
	LanguageCompiler.generate_instance_dictionary English, dict0
	a = English.parse "I ran with the dog"
	assert_not_nil a.parse
  end
end
