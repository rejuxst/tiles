require 'rexml/document'
require 'rexml/element'
module Database
#############################################################################################################
# Databases record overall game information including table information
# The main game database includes definitions on how to structure db elements
# 
# Instances can have subinstances and data:
# -- Data has a unique identifier understood by the Object Class. This Identifier should be a string
# -- but it can be anything. This ID is NOT a GUID it is only used be the loading processor to process
# -- the data.
#	XML Instance Format:
#<instance ID=#### GUID=#### DBID=####>
#	<!-- All element IID are referenced via their hosts IID so for a db item its => instance.db.item
#	<!-- Class type is not used by the parser will only exist in pretty-print mode -->
#	<instance GUID=####  SID=#### type=local class=Classtype>
#		<!-- ID on data is source information that helps the host instance -->
#		<!-- Identify its use
#		<data GUID=#### type=Integer	ID=####	>12030123</data>
#		<data GUID=#### type=String	ID=####	>Data</data>
#		<data GUID=#### type=BLOB	ID=####	>(@@*bj8#*$234</data>
#		<!-- References are either Global or Locals -->
#		<!-- Local References are indexed from the db of the element ID 0 points to the dbs host -->
#		<data GUID=#### type=GlobalReference	>123.123.123.45		</data>
#		<data ID=####   type=LocalReference	>000.000.123.123.123.45</data>
#		<!-- The above two are equivalent locations -->
#	</instance>
#<instance>
#####################################
# NOTE Should redesign to be transactional
#####################################
# UID Format:
# UID are global identifies that allow referencing objects on a global basis. The format is:
# @ or %  >>>> Each UID regardless of scope should *ALWAYS* be prepended with either of these.
#	    >>>> @: The UID is references at a global scope. When recusively parsing this UID
#	    >>>>>>>> always convert the @ to % once outside the highest level db in a db structure
# >##>##    >>>> Each UID is a hierarchical reference and each :## is the current db levels entry index
#	    >>>> thus this example value is two levels deep from the reference's db context
#	    >>>> This format is designed to be consumed at >## for easy "##".to_sym to convert to
#	    >>>> Symbols used by the databases indexing method
#TODO: Create a uid class to allow encapsulated guid management	     
# Ex)
#  @####>####>####
#  @l>####>####>####
#  @g>14512>123923>15012333 >>>>> This is a global pointer to an instance 3 levels below the global database
# UID Usage:
# 	All UIDs 
#
#
####################################
#############################################################################################################
## Database Transactional model
  def add_to_db(input,as = :instance)
	case as
	  when :instance
		input.init_db(self,assign_guid(input))
	  when :data
		# Dunno Yet
	  else
		raise "Tried to add_to_db on #{self} with unknown as format => #{as}"
	end
  end
  def remove_from_db(input,as = :instance)
	case as
          when :instance
                remove_guid(input) 
          when :data
                # Dunno Yet
          else
                raise "Tried to add_to_db on #{self} with unknown as format => #{as}"
        end
  end
#TODO Add inter_db transactors so all db control functions can be privatized

####################################
class UID ## Not in use currently
  def initialize(string)

  end
  def self.from_string(string)
	return UID.new(string)
  end
  def is_local?(input)
  end
  def is_global?(input)
	return !self.is_local?(input)
  end
  def top_id(input,as = Symbol)
	output = ''
  end
end
# Actual Database Access primitives
  attr_reader :db_parent
  attr_reader :guid,:sid
  attr_reader :data,:instances

  def self.read_db(xmlstring)
	
  end
  def write_db(file)
	file << db_dump()
  end
  def init_db(parent,guid,sid=nil)
	set_sid(sid);
	set_guid(guid);
	@db_parent=parent;
	@instances = {}
	@data = {}
  end
  def destroy_record_self()
  # Destroy the record of one's self in the containing db
  	return db_parent.remove_guid(self.guid)
  end
###################################################################
# Instance db control functions
  def find_instance(input,as = :guid)
  # Look up a instance in this database using guid
  #TODO: Extend this function to account for diffrent types of instance lookups
  #TODO: Extend this to support function aliasing to database instances
  #TODO: Prevent this function from returning guids that point to non-instances (e.g data)
	return lookup_guid(input);	
  end
###################################################################
# General DB lookup functions
  def lookup_guid(input_guid)
  # Uses the input guid to search for an object. This follows standard GUID format
	if(input_guid.class == Symbol) # Assume that GUID is for this level only
		db_lookup(input_guid); 
	elsif(input_guid.class == String)
		# GUID consume
	else
raise <<EOF
Record::guid_lookup failed when #{input_guid} was passed to Record::guid_lookup.
Expected class to be Symbol or String and got #{input_guid.class} instead.
EOF
  	end
  end
  def db_lookup(db_index)
	return instances[db_index.to_sym];
  rescue 
	raise "Unable to translate db_lookup from input db_index => #{db_index} "
  end 
###################################################################
# Sub GUID management functions
###TODO: Add methodology for preserving recently used GUIDs 
######## so references don't react unexpectedly.
  def assign_guid(input_instance)
	output = get_guid(input_instance)
	return output unless output.nil?
	i = 1;
	i = i +1 until instances[i.to_s.to_sym].nil?
	@instances[i.to_s.to_sym]= input_instance;
	return i.to_s
  end
  def remove_guid(input_guid)
	return false if instances[input_guid.to_s.to_sym]
	instances[input_guid.to_s.to_sym] = nil;
	return true; 
  rescue
	raise "Input GUID not of the correct format #{input_guid}"
  end
###################################################################
###################################################################
#TODO: Make these Record/DB private functions
###### Maybe make them non-private for private-distros?
  def set_guid(input_guid)
  # set_guid(guid): Sets the GUID of this object. (This should only be called by the database adding this object)
	return @guid=input_guid
  end
  def set_sid(sid)
	return @sid=sid
  end
  def get_guid(input_item)
	return nil;	#TODO Use get_guid to prevent repeated guid assignment
  end
################################################################### 
  def for_each_instance(&blk)
	@instances.each_value{|v| yield v}
  end
  def for_each_data(&blk)
	@data.each_value{|v| yield v}
  end
  def db_dump?()
	return true;
  end
  def db_dump()
  # db_dump:
  # Returns the dump of this instances context as a REXML::Element
  # Recursivly adds the sub data and instances in the context
	this_db = REXML::Element.new 'instance'
	this_db.add_attribute('GUID',@guid);
	this_db.add_attribute('SID',@sid);
	this_db.add_attribute('type','local');
	this_db.add_attribute('class',"#{self.class}");
	for_each_data do |d|
		this_db.add_element(Database.convert_to_data(d)) if Database.is_data?(d)
	end
	for_each_instance do |i|
		this_db.add_element(i.db_dump) if i.db_dump?()
	end	
	return this_db;
  end
end
