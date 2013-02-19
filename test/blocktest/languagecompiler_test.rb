require 'pry'
require 'polyglot'
require 'treetop'
require 'treetop/linguisticsparser.treetop'
require 'lang/english'
require 'lang/englishparser'
require 'treetop/compiler.treetop'

class Test_LanguageCompiler < Test::Unit::TestCase
	Tiles::Application::Configuration.use_default_configuration rescue nil
	::Linguistics.parser= ::LinguisticsParser.new 
  def test_interactive

	assert_not_nil c = LanguageCompiler.parse(
				'@var : A+
				% Comment
				@bar : B+'
			), LanguageCompiler.failure_reason

  end
end
