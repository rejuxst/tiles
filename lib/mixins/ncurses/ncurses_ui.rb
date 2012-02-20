require 'ncurses'
module Ncurses
	class UI < UI
		def initialize
			Ncurses.initscr	
			Ncurses.cbreak           # provide unbuffered input
			Ncurses.noecho           # turn off input echoing
			Ncurses.nonl             # turn off newline translation	
			Ncurses.timeout(-1)				
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
						Ncurses.mvaddstr(x, y, "#{($thisgame.map.tile(x,y)).ASCII}") 
					else
						actors = $thisgame.map.tile(x,y).things.find {|t| t.class <= Actor}#$thisgame.map.tile(x,y).things.find
						c = $thisgame.map.tile(x,y).things[0]
						c = actors if !actors.nil? 
						Ncurses.mvaddstr(x, y, "#{c.ASCII}") 
					end
				end
			end
		end
		def close
			sleep(2.5)
			Ncurses.endwin
		end
		def getevent
			return Ncurses.stdscr.getch
		end

	end

end