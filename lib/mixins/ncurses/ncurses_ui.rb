case RUBY_PLATFORM
	when /linux/ then require 'ncurses'
	when /darwin/ then require 'curses'
end
if(/linux/.match(RUBY_PLATFORM).nil? && /darwin/.match(RUBY_PLATFORM).nil?)
#require 'ffi-ncurses' # Use ncurses for Windows and non-curses systems
end
require 'UI'
# export RUBY_FFI_NCURSES_LIB=/lib/libncursesw.so.5.9
# ^ Run the above line if the FFI::Ncurses library isn't linking

module Ncurses
	include Curses  unless /linux/ === RUBY_PLATFORM 
	
	def self.init_screen
		initscr
		if /linux/ === RUBY_PLATFORM
			self.define_singleton_method(:getch) { self.stdscr.getch } 
		end
	end
	def self.close_screen
		endwin
	end
	def self.timeout=(input)
		self.timeout(input)
	end
	def self.setpos(x,y)
		move(x,y)
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
		if /linux/ === RUBY_PLATFORM
			Ncurses.stdscr.intrflush(false)
			Ncurses.stdscr.keypad(true) 
		end
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
		r = game.map.rows
		c =  game.map.columns
		r.times do |x|
			c.times do |y|
				Ncurses.setpos(x,y)
				t = game.map.tile(x,y)
				Ncurses.addstr (
					(t.find_if {|t| t.class <= Actor} || t).ASCII
				)
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
	def request_inbound_package
		Ncurses.getch.ord.chr
	end
	def outbound_package(package)
		 sanitize(package)
	end
end 


if /linux/ == RUBY_PLATFORM || /darwin/ === RUBY_PLATFORM
module Curses; end if !defined? Curses
Curses::UI = Ncurses::UI
Curses::Channel = Ncurses::Channel
Curses::View = Ncurses::View
Ncurses = Curses 
end
