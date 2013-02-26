module Tiles
end
%w[ app/application.rb app/config.rb app/launcher.rb ].each { |r| require r }
%w[
core/database.rb
core/reference.rb
core/generic.rb
core/responsive.rb
core/active.rb
core/thing.rb
core/ui.rb 
core/player.rb
core/game.rb
core/nonactor.rb
core/actor.rb
core/action.rb
core/equation.rb
core/log.rb
core/map.rb
core/property.rb
core/script.rb
core/tile.rb
].each { |r| require r }
%w[
lang/language.rb
lang/linguistics.rb
lang/dictionary.rb
lang/languagecompiler.rb
].each { |r| require r }

