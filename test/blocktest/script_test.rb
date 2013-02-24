require 'pry'
require 'polyglot'
require 'treetop'
require 'treetop/scriptable'
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
		puts (b) ? b : a.failure_reason
		binding.pry
	end
end
