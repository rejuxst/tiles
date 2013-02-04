require 'pry'
require 'mixins/ncurses/ncurses_ui'
class Human < Player
	def init(arghash = {})
	end
	def process_event(event)
		# There are lots of cool ways to do this in ruby
		while 1 # Loop until valid input
			i = Move.down(controls[0])   if event == 'w'
			i = Move.left(controls[0])   if event == 'd'
			i = Move.right(controls[0])  if event == 'a'
			i = Move.up(controls[0])     if event == 's'
			return i 		    unless i.nil?
			event = @ui.getevent 	    if i.nil?
		end
	end 
end
class SuperHuman_DEBUG < Human
	def init(arghash = {})
		super
		@ui = SuperHuman_DEBUG::INTERACTIVEUI.new(self)
		@useshell = false;
	end
	def process_event(event)
		if !@useshell 
			return super unless event == 'p'	# Act as a normal Human
			@useshell = true;
		end
		while(1)
		@ui.render
		unless (@ui.sendchar(@ui.getevent()))
			@useshell = false;
			return super(@ui.getevent())
		end
		end
	end

	class INTERACTIVEUI < ::Ncurses::UI
		attr_accessor :iline,:stream
		def initialize(owner = nil)
			super()
			@__ccontext = self
			@iline = ""
			@max_length = 15
			@stream = Array.new(0,"")
			@owner = owner
		end
		def render
			Ncurses.nl
			render_mainwindow
			render_character_ui
			render_shell
			Ncurses.nl
			Ncurses.refresh
		end
		def render_shell
			rowtop = $thisgame.map.rows + 3
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
		def render_character_ui
			return nil if @owner.nil?
			left_col = $thisgame.map.columns + 3
			Ncurses.setpos(0,left_col)
			Ncurses.addstr("Player 1")
			Ncurses.setpos(1,left_col)	
			Ncurses.addstr("HP: #{'*' * @owner.character.hp}")
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
