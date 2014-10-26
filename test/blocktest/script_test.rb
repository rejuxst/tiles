require 'polyglot'
require 'treetop'
require 'grammars/scriptable'
class Test_Script < Test::Unit::TestCase
  Tiles::Application::Configuration.use_default_configuration rescue nil
  def test_interactive
  	a = ScriptableParser.new
  	b = a.parse '
  		\hello
  		\begin
  		\begin
  			WAAA
  		\end
  		\end
  		\goodbye
  	'
  	assert_not_nil b, a.failure_reason
  end
end
