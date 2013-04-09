require 'pry'
class Dungeon < Map
	def init

		rows.set 	20
		columns.set 	20
		p = create_primitive
		(0..(rows - 1)).to_a.product((0..(columns-1)).to_a).each do |tup|	
			tiles[tup[0],tup[1]]= p[tup[0]][tup[1]].new :owner => self
		end
		(0..(rows - 1)).to_a.product((0..(columns-1)).to_a).each do |tup|	
			r = tup[0]
			c = tup[1]
			tile = tiles[r,c]
			tile.add_reference "up",   	tiles[r+1,c]
			tile.add_reference "down", 	tiles[r-1,c]
			tile.add_reference "left", 	tiles[r,c-1]
			tile.add_reference "right", 	tiles[r,c+1]
		end
	end
	def create_primitive
		#{"X" => Wall,:"." => Ground, :D => Door, :"~" => Water}
		map = {}
		map["X"] = Wall 
		map["."] = Ground
		map["~"] = Water
		map["D"] = Door
		str = ""
		str << "....................\n"
		str << ".XXXXXXX............\n"
		str << ".X.....X............\n"
		str << ".X.....X............\n"
		str << ".X.....X............\n"
		str << ".D.....X............\n"
		str << ".XXXXXXX............\n"
		str << ".............~~~....\n"
		str << ".............~~~....\n"
		str << ".............~~~....\n"
		str << "....................\n"
		str << "....................\n"*9
		output = []
		r = 0
		c = 0
		str.each_char do |s|
			output[r] = Array.new if output[r].nil?
			output[r] << map[s] unless s == "\n"
			r += 1 if  s == "\n"
		end
		return output
	end
end
