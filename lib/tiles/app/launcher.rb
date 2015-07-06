class  Tiles::Launcher
  class << self
	############################
		public #############
		attr_reader :game, :manager
		def launch game, opts = {}, &blk
			self.debug_mode= (opts[:debug] == true)
			load_debug_suite if debug_mode?
			load_tiles_library opts
			@game_string, @input_blk, @opts = game, blk, opts
			#safe_level = opts[:safe_level] if opts[:safe_level].class <= Fixnum
			#$SAFE = safe_level
			Tiles::Launcher.setup
			Tiles::Launcher.run
		rescue Exception => e
			if defined? Ncurses
				Ncurses.echo
				Ncurses.nocbreak
				Ncurses.nl
				Ncurses.endwin if /linux/ === RUBY_PLATFORM
			end
			debug_mode? ? binding.pry : raise(e)
		ensure
			#Thread.kill(@game_thread)
		end

		def run
			@application.run
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
			@configuration= Tiles::Application::Configuration.last_config ||
					Tiles::Application::Configuration.use_default_configuration
			load_application_from @opts[:app_dir]
			@input_blk ||= Proc.new {}
			game = ::Tiles::Application::ObjectSpace.lookup_class(@game_string.to_s.capitalize)
			#TODO: This is a HUGE security flaw fix it
			raise "#{game} is not a Tiles::Game" unless game <= Game
			@game = game.new
			@application = Tiles::Application.new(
						:game => @game,
						:valid_channels => ["Channel", "Ncurses::Channel"]
					) { |g,a| @input_blk.call(g,a) }
			self.freeze
		end

		def debug_mode?
			@debug_mode == true
		end

	############################

		private

		def debug_mode=(input)
			(@debug_mode = input).freeze
		end

		def load_application_from dir
			dir = File.absolute_path (dir || Dir.pwd)
			appt = File.join dir, 'app'
			Dir.foreach(appt).each do |ent|
				next if [/^\./].any? {|m| !ent.match(m).nil? }
				f_path = File.expand_path File.join(appt, ent)
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
			require 'tiles'
			return nil
			$LOAD_PATH << File.absolute_path(dir)
			core = File.join(File.absolute_path(dir),'core')
			Dir.open(core) do |ent|
				ent.entries.each do |f|
					unless File.directory?(	File.join(core,f)) ||
								!(f.match(/\.gitignore/).nil?) ||
								!(f.match(/\.swp/).nil?
								)
						begin
							gem_original_require File.expand_path File.join(ent.to_path,f.partition('.')[0])
						rescue Exception => e
							raise <<-EOF
								| Failed to load file correctly #{File.join(ent.to_path,f.partition('.')[0])} :
								| => #{e}
								| #{e.backtrace.join("\n")}
							EOF
						end
					end
				end

			end
		end

		def load_debug_suite
			require 'pry'
		end

		def enter_debug_mode in_binding = nil
			if @game.nil?
				puts "No application instance loaded into launcher (self)"
				(in_binding || binding).pry
			else
				(in_binding || @application).pry
			end
		end

		def game_loop(game_string)
		end
	############################
	end
end
