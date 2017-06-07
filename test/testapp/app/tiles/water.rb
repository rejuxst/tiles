class Water < Tile
  add_response :move, :target, :effect => "actor#hp = actor#hp - 1"
  def init(args)
  	@ASCII = '~'
  end
end
