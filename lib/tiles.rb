module Tiles
end
%w[
  app/application
  app/security
  app/config
  app/launcher
  app/security
  app/objectspace
  modules/database
  core/reference
  app/factories
  modules/generic
  modules/responsive
  modules/active
  app/eventhandler
  core/basicobject
  core/event
  core/thing
  core/ui
  core/player
  core/game
  core/nonactor
  core/actor
  core/action
  core/equation
  core/log
  core/map
  core/property
  core/script
  core/tile
  lang/language
  lang/dictionary
  lang/linguistics
  lang/languagecompiler
].each { |r| require "tiles/#{r}" }

