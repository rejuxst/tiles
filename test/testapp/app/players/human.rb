require 'pry'
require 'mixins/ncurses/ncurses_ui'
class Human < Player
	def init(arghash = {})
	end
end
class SuperHuman_DEBUG < Human
	attr_reader :ui
	def init(arghash = {})
		super
		@useshell = false;
	end
	class UI <   ::Ncurses::UI
		def take_turn
			nil until (event = request_inbound_package).match /[wasd]/
			outbound_package $thisgame
			case event
				when 'w' then  Proc.new { Move.down(controls["character"])  } 
				when 'd' then  Proc.new { Move.left(controls["character"])  }
				when 'a' then  Proc.new { Move.right(controls["character"]) } 
				when 's' then  Proc.new { Move.up(controls["character"])    } 
			end
			
		end
		def request_inbound_package
			str = super
			str.is_a?(String) ? str : ''
		end
	end
	class Channel < ::Ncurses::Channel
		def initialize(input)
			super(input)
			@view = View.new
		end
		def outbound_package(package)
			@view.recieve_package sanitize(package)
		end
	end	
	class View < ::Ncurses::View
		attr_accessor :iline,:stream
		def initialize(owner = nil)
			super()
			@__ccontext = self
			@iline = ""
			@max_length = 15
			@stream = Array.new(0,"")
			@owner = owner
		end
		def recieve_package package
			render package
		end
		def render package
			Ncurses.nl
			render_mainwindow package
			render_character_ui package
			render_shell package
			Ncurses.nl
			Ncurses.refresh
		end
		def render_shell game
			rowtop = game.map.rows + 3
			r = 0;# stream.length;
			stream.each do |l|
				Ncurses.setpos(rowtop+r,0)
				Ncurses.addstr(l)
				r = r+1
			end
			Ncurses.setpos(rowtop+stream.length,0)
			Ncurses.addstr("TILES>>> #{iline}")
			#Ncurses.mvaddstr(rowtop+stream.length+1,0,">>#{iline}")
		end
		def render_character_ui game
			@owner = game.players[0]
			left_col = game.map.columns + 3
			Ncurses.setpos(0,left_col)
			Ncurses.addstr("Player 1")
			Ncurses.setpos(1,left_col)	
			Ncurses.addstr("HP: #{'X' * @owner.character.hp}#{'-' * ( @owner.character.max_hp -  @owner.character.hp )}")
		end
		def sendchar(input)
			return process_shell if input == "\n".ord or input == "\r".ord or input == 10
			iline << input.chr;
			return true;
		end
		def process_shell
			stream.delete_at(1) while stream.length >= @max_length
			if iline == 'exit' or iline == 'exit()'
				stream << iline
				return false;	
			end
			return true if iline.empty?
			stream << "TILES>>> #{iline}"
			begin
				binding.pry and initialize() and render() if(iline == 'pry')
				n = "#{eval(iline)}" 
			rescue 
				n = "#{$!}"
				Ncurses.close_screen
				initialize
				render
			end
			
			stream << n
			iline.clear
			return true;
		end
	end	
	
end
