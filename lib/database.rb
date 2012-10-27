require 'rexml/document'
require 'rexml/element'
module Database
#############################################################################################################
# Databases record overall game information including table information
# A database is a module for extending Objects to allow inter object communication and maintinence.  
# An Object that is a database is recordable, can create other Objects that can be recorded, and
# has easy self contained methods for describing itself to others.
# 
# Why do we need a database structure? 
#  The primary reason is to allow a smooth process for saving data in a concise manner, and to allow
#  for object refrencing and imiplicit ownership. Ownership is a integral part of this game structure
#  but it is not 100% absolute. This allows a designer to use the database as a method of managing 
#  single owner operations, while avoiding making it an issue.
#
#################
# Design priciples:
# 1) For a given Game environement there should be a "defacto" global database. This is not a hard requirement
#    but more of an imlpication of using this library in its standard structure. Formally there must be a 
#    clear recursive method call from one object that records ALL information on a game, in a manner, that
#    prevents unexpected state on reinstanciation.
# 2) No cyclical ownership: database is intended to be utilized in a tree structure not a directed graph.
#    this requirement may or may not be enforced during run time. 
#	NOTE: Not sure if this is needed
#	NOTE: This only applies to database parent child relationships. cyclical references are fine
# 3) When a Object is removed from the game it implies that all its childe DBs and Data are destroyed
# 4) Only other databases can be referenced from a given database. This means objects that are not 
#    also dbs can only be refrenced via there owner (Ruby uses smart pointers and thus object destruction
#    is not as clean cut.)
#      4a) An extention to this is that databases are designed to have a creation and destruction routine
#           but data (or non-db objects) dont have to exist in that manner.
# 5) Objects can be moved from one database to another, and can thus change "owners"
# 6) Databases can and should store relational requirements for its elements. Actions on elements in the
#    database that are achieved via the given database should be trackable and effectable in a 
#    designable manner. (i.e If a enemy spell destroys all potions a player owns the player object should
#    be made aware of it.
##################
# Database Entries and Structure:
# Instance: Another Database whose "parent_db" is the current database. An instance is by definition
#           a Object that inludes Database. Due to this there is no explicit filtering for this on storage
# Data:     Any Object that is NOT a Database. This is intended to be used for MACROS or helper objects 
#	    which cannot own other objects and only has meaning to the owning db. It shouldn't need
#           to be aware of who owns it in any functional manner. (Though the designer can add that as needed)
# Reference: A reference to another Database. This does not imply ownership and destruction of either object
#            doesn't imply any effect on the object unless enforced by the database.
# Relative Reference: A reference to another Database or Object. A relative reference is a recorded path 
#                     from one database to an Object. This path can be any number of hops and can
#		      utilize any db serach method to resolve to its destination (i.e "My Allies Bow"
#		      would be a reference that points to your ally and resolves your allies bow 
#                     reference to his actual bow object).
# Requirements: All References must be referencible with a NON-NUMERIC key (that is 1/"1" is not allowed)
#		
#######################
# Storing a Database:
# XML Instance Format:
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
# Actual Storage:
# Everything is stored as a hash. Access can be via an integer,string or symbol.
# Any integer access implies a ID lookup, for an owned object it translates to :"#". 
#   []= is not defined for integers (though might define a key that implies add_to_db)
# Any symbol lookup can be an instance or refrence lookup. A symbol will be passed as is
# for lookup (implying a key lookup). If it returns nil it will convert to a string,
# and check that its not numeric then do a reference lookup.
#  
#
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
