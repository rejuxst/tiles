module Database
# Databases record overall game information including table information
# The main game database includes definitions on how to structure db elements
# Custom db Format: <ID|IID:Data>
# - < opens an entry
# - > closes an entry
# - | seperates Definition ID and Instance ID
# - : seperates Instance ID and Data
# - & braces a Definition
# - & braces an Instance
# - # braces a Numerical 	datatype 
# - " braces a String		datatype
# - $ braces a Symbol		datatype
# - ~ braces a BLOB 		datatype
# - * braces a NESTED 		datatype
#	Definition:
#	<&ID:N"Data"N^"SuperClass"^!PID:Data!MIDMM"Data"MR"Action"|$via$,$all:M"data"MR&>
#		- N braces a class Name
#		- ! braces a property	Note: Property Data in a definition corresponds to the default value upon creation
#		- ^ braces a Superclass name
#		- M braces a method
#		- R braces a respond_to block which is of the format "Action"|access_type:method
#			- if method is of datatype string it is the name of the method to call
#			- if method is a MM method block the contained block will be packaged into
#			- if method is a symbol it is saved to the respond_to tree as is 
#	Instance:
#	<@ID|IID:^owner^!PID:#Data#!!PID:"Data"!@>
#		- ! braces a property
#		- ^ braces an owner IID
	def self.find_datatype_char(input)
		return case input
			when :number
				'#'
			when :string
				'"'
			when :blob
				'~'
			when :nested
				'*'
		end
	end
	def self.dbentry_data(input)
		case 
			when input.is_a?(Numeric)
				return "##{input}#"
			when input.is_a?(String)
				i = ""
				input.each {|c| i << '\\' if (c == "\"")||(c == "\\"); i << c}
				return "\"#{i}\""
			when  input.is_a?(Symbol)
				return "$#{input}$"
			else
				raise "This Function doesn't work for this datatype"
		end
	end
	class Global
		def self.create
			$GDB = Global.new
		end
		def add_to_definition(classdef,item,as = :property)
			case as
				when :property
					Global.find_by_name(classdef.to_s).property_list << Global.find_by_name(item) if item.class == String  
				else
			end
			
		end
		def add_definition
		
		end
		
	end
	class Active
		def self.execute dbpath, db_static
		
		end
	end
	class Static
		attr_accessor :entry_list, :dbfile
		attr_reader :definition_list, :instance_list
		def self.execute dbpath
			db_static = Database::Static.new
			db_static.dbfile = File.new(dbpath,"r")
			db_static.open_context
			db_static.dbfile.each_char {|c| db_static.procchar(c)}
			db_static.complete_context
			db_static.process
			db_static.dbfile.close()
			return db_static
		end
		def initialize 
			@context = 	[]
			@entry_list = []
			@definition_list = []
			@instance_list = []
			NoContext.new(@context,self)
		end
		def open_context
			NoContext.new(@context,self)
		end
		def procline line 	## Line Processing
			line.each {|c| procchar(c)}
		end
		def procchar c		## Char Processing
			#puts "----   #{c}"
			@context.last.preformresponse(c)
		end
		def addentry e		## add an entry to the list
			@entry_list << e
		end
		def complete_context
			while not @context.length == 0
				@context.last.pop
			end
		end
		def process
			@definition_list = []
			@entry_list.each do  |entry|
				case(entry.type)
					when :definition
						@definition_list << Definition.new(entry)
					when :instance
					
					else
						raise "Error invalid type of entry #{entry.type}\n"
				end
			end
		end
		def write_new(path)
			@dbfile = File.new(path,"w")
			@definition_list.each{|d| @dbfile.puts d.dbentry} 
			@instance_list.each{|d| @dbfile.puts d.dbentry} 
		end
	end
	class Entry
		attr_accessor :data,:id,:iid,:type
		def initialize
			@data = []
			@id = 0
			@iid = 0
			@type = :none
		end
	end
	class Context
		attr_accessor :list,:db,:last
		attr_accessor :data,:entry
		@@char = ""
		def self.char
			return @@char
		end
		def initialize(list,db,entry = nil)
			@list = list
			@db = db
			@last = @list.last
			@list << self
			@entry = entry
			@data = ""
			init
			#print ">"*(@list.count) + " #{self.class},#{@entry}\n"
		end
		def init
		end
		def preformresponse(input)		
		end
		def push(item,entry = nil)
			item.new(@list,@db,@entry)
		end
		def pop(type = :entry,data = @entry)
			@list.pop 
			@last.take(type,data) if !@last.nil?
			#print "<"*(@list.count+1) + " #{self.class}: #{@entry}\n"
		end
		def take(as,data)
			if (as == :id) || (as == :iid) || (as == :data)
				@last.take(as,data) if @entry.nil?
			end
			case as
				when :entry
					@entry = data
				when :data
					@entry.data << data
				when :id
					@entry.id = data  
				when :iid
					@entry.iid = data
				when :none
				else
					raise "Unexpected type to take #{__LINE__} : #{as.to_s}"
			end
		end
	end
	class NoContext < Context
		@@char = "<"
		def preformresponse(input)
			case input 
				when "<"
					push(EntryContext)
				when "\n"
				else
			end
		end
	end
	class DefinitionContext < Context
		@@char = "&"
		def init
			@entry.type = :definition
		end
		def preformresponse(input)
			case input 
				when "&"	# Open a definition
					pop
				when "!"
					push(PropertiesContext)	
				when "@"
					push(PlayerContext)	
				when "^"
					push(SuperClassContext)
				when "#"
					push(NumericalContext)	
				when "N"
					push(NameContext)
				when "\n", " "
				else
			end
		end
	end
	class InstanceContext < Context
		@@char = "I"
		def init
			@entry.type = :instance
		end
		def preformresponse(input)
			case input 
				when "O", "T", "M", "@", "L"	# Open a definition
				when "\n", " ", "\t"
				else
					push(DataContext)
					@list.last.preformresponse(input)
			end
		end
	end
	class EntryContext < Context
		@@char = ">"
		def init
			@entry = Entry.new
		end
		def preformresponse(input)
			case input 
				when "&"	#Open a definition
					push(DefinitionContext)
					push(IDContext)
				when "I" 
					push(InstanceContext)
					push(IDContext)
				when ">"
					@db.addentry(@entry)
					pop(:none)
					#print "#{@entry} ----ENDENTRY\n"
				when "\n", " "
				else
			end
		end
	end
	class DataContext < Context
		@@char = ""
		def preformresponse(input)
			case input 
				when "\n", " "
				else
					pop(:none)
			end
		end
	end
	class SuperClassContext < Context
		@@char = '^'
		def init
			@entry = Entry.new
			@entry.type = :superclass 
		end
		def preformresponse(input)
			case input 
				when '"'
					push(StringContext)
				when "\n", " ", "\t"
				else
					pop(:data,@entry)
			end
		end
	end
	class NameContext < Context
		@@char = 'N'
		def init
			@entry = Entry.new
			@entry.type = :name 
		end
		def preformresponse(input)
			case input 
				when '"'
					push(StringContext)
				when "\n", " ", "\t"
				else
					pop(:data,@entry)
			end
		end
	end
	class PropertiesContext < Context
		@@char = '!'
		def init
			@entry = Entry.new
			@entry.type = :property
			push(IDContext)
		end
		def preformresponse(input)
			case input 
				when "!"
					pop(:data,@entry)
				when "#"
					push(NumericalContext)
				when "\n", " "
				else
					raise "\nRecieved unexpected character in db file: #{input}\n data is #{data.to_i}\n"
			end
		end
	end
	class NumericalContext < Context
		@@char = '#'
		def init
			@entry = Entry.new
			@entry.type = :number
		end
		def preformresponse(input)
			case input 
				when "#"
					@data = @data.to_i
					@entry.data = @data
					pop(:data,@entry)
				when "1","2","3","4","5","6","7","8","9","0"
					@data << input
				when "\n"
				else
					raise "\nRecieved unexpected character in db file: #{input}\n data is #{data.to_i}\n"
			end
		end
	end
	class StringContext < Context
		@@char = '"'
		def init
			@entry = Entry.new
			@entry.type = :string
			@lastchar = "c"
			@data = ""
		end
		def preformresponse(input)
			case input 
				when '"'
					if @lastchar == "\\"
						@data << input
					else
						@entry.data = @data
						pop(:data,@entry)
					end
				when '\\'
					@data 
				else
					@data << input
			end
			@lastchar = input
		end
	end
	class IIDContext < Context
		@@char = "123456789"
		def preformresponse(input)
			case input 
				when ":"
					pop(:iid,@data.to_i)
				when "1","2","3","4","5","6","7","8","9","0"
					@data << input
				when "\n"
				else
					raise "Recieved unexpected character in db file"
			end
		end
	end
	class IDContext < Context
		@@char = "123456789"
		def preformresponse(input)
			case input 
				when "|"	#Open a definition
					pop(:id,@data.to_i)
					push(IIDContext)
				when ":"
					pop(:id,@data.to_i)
				when "1","2","3","4","5","6","7","8","9","0"
					@data << input
				when "\n"
				else
					raise "\nRecieved unexpected character in db file: #{input}\n data is #{data.to_i}\n"
			end
		end
	end
	class Definition
		attr_reader :owner,:classname,:value,:property_list,:id
		def initialize(entry)
			@owner = ""
			@classname = ""
			@property_list = []
			@id = 0
			@value = nil
			entry.data.each{ |en|
				case(en.type)
					when :superclass, :owner
						set_owner(en)
					when :name
						set_classname(en)
					when :property
						add_property(en)
					else
						set_value(en)
				end
			}
			@id = entry.id
		end
		def set_owner(entry)
			@owner = entry.data[0].data
		end
		def set_classname(entry)
			@classname = entry.data[0].data if entry.data[0].type.to_s == "string" 
		end
		def set_value(entry)
			@value = {:data => entry.data, :type => entry.type}
		end
		def set_id(entry)
			@value = entry.id
		end
		def add_property(entry)
			@property_list << {:data => entry.data[0].data, :id => entry.id, :type => entry.data[0].type}
		end
		def dbentry
			entry = "<&"
			s_id = @id.to_s + ":"
			s_owner = "^\"#{@owner}\"^"
			s_classname = "N\"#{@classname}\"N"
			s_value = ""
			if !@value.nil?
				s_value_t = Database.find_datatype_char(@value[:type])
				s_value = "#{s_value_t}#{@value[:data]}#{s_value_t}" 
			end
			s_property_list = ""
			@property_list.each do |p|
				s_property_list <<  fix__for_db_property(p)
			end
			return entry + s_id + s_classname + s_owner + s_property_list + s_value + "&>"
		end
		def fix_for_db(data,type)
			case type
				when :number
					return data
				when :string
					data2 = ""
					data.each_char do |c| 
						data2 << '\\' if c == '\\' or c == '"'
						data2 << c
					end
					return data2
				when :blob
				when :nested
				else
			end
		end
		def fix__for_db_property(p)
				data = fix_for_db(p[:data],p[:type])
				entry = "!#{p[:id].to_s}#{("|" +p[:iid]) if !p[:iid].nil? }:"
				d_symbol = Database.find_datatype_char(p[:type])
				d_entry = "#{d_symbol}#{data}#{d_symbol}"
				return entry + d_entry + "!"
		end
	end
end