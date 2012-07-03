module Stream

end
class Log
# Logs are record keepers that act like active streams.
# As an active stream characters can be streamed into 
# the log and streamed out. The output stream can be 
# redirected to any output. Any output not attached
# to the log can only retrieve the last line with getl.
# Listeners can be attached to the log via callback.
# callback(object,method) will preform object.send(:"method")
# on a character by charater basis. All callback functions 
# must take in a single charater parameter.

	attr_accessor :in, :out
	attr_accessor :listeners
	def initialize
		@line = '';
		@listeners = [];
	end
	def print(line)
		line.each_char {|c| callback(c)}
		@line << line
		callback
	end
	def getl
		i = 0;
		output = ''
		@line.reverse.each_char do |c|
			output << c
			break if c == "\n" and !output.empty?
		end
	end
	def add_listener(obj,method)
		listeners << [obj,method]
	end
	def callback(c)
		listeners.each do |l|
			l[0].send(l[1],c)
		end
	end
	
end
