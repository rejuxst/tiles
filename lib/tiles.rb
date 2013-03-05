module Tiles
end
%w[ app/application.rb app/config.rb app/launcher.rb app/security app/objectspace 
].each { |r| require r }
%w[
modules/database.rb
core/reference.rb
modules/generic.rb
modules/responsive.rb
modules/active.rb
app/eventhandler.rb
core/basicobject.rb
core/event.rb
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

