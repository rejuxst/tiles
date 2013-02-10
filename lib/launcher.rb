if !defined? Tiles
	module Tiles
	end
end

class  Tiles::Launcher
class << self
############################
	public #############
	def launch(game,opts = {},&blk)
		self.debug_mode= (opts[:debug] == true)
		load_debug_suite if debug_mode?
		load_tiles_library opts
		@game_string = game
		@input_blk = blk
		@opts = opts
		safe_level = opts[:safe_level] if opts[:safe_level].class <= Fixnum
		#@game_thread = Thread.new(0 || safe_level) do |safe_level| 
		#^ Threading seems to slow it down alot
			$SAFE = safe_level
			Tiles::Launcher.setup
			Tiles::Launcher.run
		#	Thread.stop
		#end
		#@game_thread.join
		#sleep 0.1 while @game_thread.status != 'sleep'
	rescue Exception => e
		if debug_mode?
			enter_debug_mode 
		else
			raise e
		end
	ensure
		#Thread.kill(@game_thread)
	end
	def run
		@game.start
		@game.run
		@game.stop
	end
	def load_tiles_library(opts = {})
		case opts[:load_source]
			when :gem then core_load_from_gem
			when :source then core_load_from_source(opts[:source_dir])
			when :application then core_load_from_application
			else core_load_from_gem
		end
	end
	def setup		
		load_application_from @opts[:app_dir]
		@manager = Tiles::Application::Manager.new

		game = eval(@game_string.to_s.capitalize) #TODO:This is a HUGE security flaw fix it
		raise "#{game} is not a Tiles::Game" unless game <= Game
		@game = game.new
		self.freeze
		@input_blk.call @game, @manager unless @input_blk.nil?

	end
	def debug_mode?
		@debug_mode == true
	end
	def game
		@game
	end
	def manager
		@manager
	end
############################
	private
	def debug_mode=(input)
		(@debug_mode = input).freeze
	end

	def load_application_from dir
		dir = File.absolute_path (dir || Dir.pwd) 
		app = File.join dir, 'app'
		Dir.foreach(app) do |ent|
			next if [/^\./].any? {|m| !ent.match(m).nil? }
			f_path = File.expand_path File.join(app, ent)
			Dir.foreach(f_path) do |file|
				next if [/^\./].any? {|m| !file.match(m).nil? }
				gem_original_require File.expand_path File.join(f_path,file) 
			end if File.directory? f_path

		end
	end
	def core_load_from_application(dir)
	end
	def core_load_from_gem
	end
	def core_load_from_source(dir)	
		$LOAD_PATH << File.absolute_path(dir)
		core = File.absolute_path dir
		Dir.open(dir) do |ent|
			ent.entries.each do |f|
			begin
			gem_original_require File.expand_path File.join(ent.to_path,f.partition('.')[0])
			rescue Exception => e
			raise <<-EOF
Failed to load file correctly #{File.join(ent.to_path,f.partition('.')[0])} : 
=> #{e}
#{e.backtrace.join("\n")} 
			EOF
			end unless File.directory?(File.join(core,f)) || !(f.match(/\.gitignore/).nil?) || !(f.match(/\.swp/).nil?)
			end

		end
	end
	def load_debug_suite
		require 'pry'
	end
	def enter_debug_mode
		if @game.nil?
			binding.pry
		else
			@game.pry
		end	
	end
	def game_loop(game_string)
	end
############################
end
end
