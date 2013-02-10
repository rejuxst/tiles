if(/linux/.match(RUBY_PLATFORM).nil? && /darwin/.match(RUBY_PLATFORM).nil?)
#require 'ffi-ncurses/ncurses' # Use ncurses for Windows and non-curses systems
else
require 'curses'	# Use Ruby curses built-in
end
require 'UI'
# export RUBY_FFI_NCURSES_LIB=/lib/libncursesw.so.5.9
# ^ Run the above line if the FFI::Ncurses library isn't linking
module Ncurses

include Curses

unless ( /linux/.match(RUBY_PLATFORM).nil? && /darwin/.match(RUBY_PLATFORM).nil? )
#Ncurses = Curses
#Curses.define_method('mvaddstr') do |x,y,str|
#	Curses.setpos(x,y)
#	Curses.addstr(str)
#end
else
def self.init_screen
	self.initscr
end
def self.close_screen
	self.endwin
end
def timeout=(input)
	self.timeout(input)
end
end
end
class Ncurses::View < View
	def initialize
		setup
	end
	def setup
		Ncurses.init_screen	
		Ncurses.cbreak           # provide unbuffered input
		Ncurses.noecho           # turn off input echoing
		Ncurses.nonl             # turn off newline translation	
		Ncurses.timeout = -1				
	end
	def recieve_package package
		case package
			when Game then render(package)
		end
	end
	def render game
		render_mainwindow(game)
		#	Ncurses.getmaxyx(lines,columns,1)
		#Ncurses.mvaddstr(4, 19, "Hello, world!");
		Ncurses.refresh
	end
	def render_mainwindow game
		game.map.rows.times do |x|
			game.map.columns.times do |y|
				if	game.map.tile(x,y).db_empty?
					Ncurses.setpos(x,y)
					Ncurses.addstr("#{($thisgame.map.tile(x,y)).ASCII}")
					#Ncurses.mvaddstr(x, y, "#{($thisgame.map.tile(x,y)).ASCII}") 
				else
					actors = game.map.tile(x,y).find_if {|t| t.class <= Actor}
					c = game.map.tile(x,y).find_if { |t| true }
					c = actors if !actors.nil? 
					Ncurses.setpos(x,y)
					Ncurses.addstr("#{c.ASCII}")
				end
			end
		end
	end
	def close
		sleep(2.5)
		Ncurses.close_screen
	end
end
class Ncurses::UI < UI
	def initialize
		setup
	end
	def take_turn

	end
end
class Ncurses::Channel < Channel
	def initialize(input)
		@view ::Ncurses::View.new
		super(input)
	end

	def request_inbound_package
		 Ncurses.getch
	end
	def outbound_package(package)
		@view.receive_package sanitize(package)
	end
end

unless /linux/.match(RUBY_PLATFORM).nil? && /darwin/.match(RUBY_PLATFORM).nil?
Curses::UI = Ncurses::UI
Curses::Channel = Ncurses::Channel
Curses::View = Ncurses::View
Ncurses = Curses 
end
