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
attr_accessor :stream,:records,:proc_stream

def self.read_db(filename)
    db = Database.new()
    return db.read_db(filename)
end
def read_db(filename)
    stream = File.open(filename,"r");
    process_stream(stream);
end
def process_stream(stream)
    c = stream.readchar
    return self if c == nil
    records << Record.process_stream(stream) if(c == "<" and proc_stream != "\\")
    proc_stream = c
    return process_stream(stream);
end




# Actual Database Access primitives
module Record
   attr_accessor :elements,:rid,:rtype,:instance
   attr_accessor :context
   def db_dump

   end
   def update

   end
   def self.process_stream(stream)
      r = Record.new()
      r.context = :new
      return r.process_stream(stream)
   end
   def process_stream(stream)
    c = stream.readchar
    return self if c == nil

    proc_stream = c
    return process_stream(stream);
   end
end
module RElement
  attr_accessor :data,:type
  def initialize

  end
end
end
