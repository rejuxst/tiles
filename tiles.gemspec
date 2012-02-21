Gem::Specification.new do |s|
  s.name        = 'tiles'
  s.version     = '0.0.0'
  s.date        = '2012-02-15'
  s.summary     = "Game Engine for Tile based games"
  s.description = <<-EOF
		This gem supports rapid development of 2D tile and turn based games for offline
		and online usage.
EOF
  s.add_dependency('ffi-ncurses', '>= 0.4.0')
  s.executables << 'tiles'
  s.authors     = ["Rejuxst"]
  s.email       = "wer123hitech@gmail.com"
  s.files       = Dir['lib/**/*.rb'] + Dir['lib/mixins/**/*.rb']
  s.homepage    = "https://github.com/rejuxst/tiles"
end
