require 'pry'
class Dungeon < Map
	def init

		@rows = 	20
		@columns = 	20
		p = create_primitive
		r = 0
		c = 0
		@tiles = Array.new(@rows) do |e|
			e = Array.new(@columns) do |e1|
				e1 =p[r][c].new(:owner => self)
				c += 1
				add_to_db e1
				next e1	
			end
			r += 1
			c = 0
			next e
		end
	end
	def create_primitive
		map = {}
		map["X"] = Wall #{:X => Wall,:"." => Ground, :D => Door, :"~" => Water}
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
