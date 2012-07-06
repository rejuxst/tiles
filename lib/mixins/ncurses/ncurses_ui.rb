if(/linux/.match(RUBY_PLATFORM).nil?)
#require 'ffi-ncurses/ncurses' # Use ncurses for Windows and non-curses systems
else
require 'curses'	# Use Ruby curses built-in
end
require 'UI'
# export RUBY_FFI_NCURSES_LIB=/lib/libncursesw.so.5.9
# ^ Run the above line if the FFI::Ncurses library isn't linking
module Ncurses
include Curses

unless /linux/.match(RUBY_PLATFORM).nil?
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
	class UI < UI
		def initialize
			Ncurses.init_screen	
			Ncurses.cbreak           # provide unbuffered input
			Ncurses.noecho           # turn off input echoing
			Ncurses.nonl             # turn off newline translation	
			Ncurses.timeout = -1				
		end
		def render
			render_mainwindow
			#	Ncurses.getmaxyx(lines,columns,1)
			#Ncurses.mvaddstr(4, 19, "Hello, world!");
			Ncurses.refresh
		end
		def render_mainwindow
			$thisgame.map.rows.times do |x|
				$thisgame.map.columns.times do |y|
					if	$thisgame.map.tile(x,y).things.length == 0
						Ncurses.setpos(x,y)
						Ncurses.addstr("#{($thisgame.map.tile(x,y)).ASCII}")
						#Ncurses.mvaddstr(x, y, "#{($thisgame.map.tile(x,y)).ASCII}") 
					else
						actors = $thisgame.map.tile(x,y).things.find {|t| t.class <= Actor}
						c = $thisgame.map.tile(x,y).things[0]
						c = actors if !actors.nil? 
						#Ncurses.mvaddstr(x, y, "#{c.ASCII}") 
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
		def getevent
			#binding.pry
			return Ncurses.getch

			#binding.pry
		end

	end
end
unless /linux/.match(RUBY_PLATFORM).nil?
Curses::UI = Ncurses::UI
Ncurses = Curses 
end
