require 'pry'
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
### Class Functions ################
  def self.read_db(xmlstring)	
  end
  def self.is_database?(input)
	return input.class.include?(Database) 
  end
  def self.is_data?(input)
	return !is_database?(input)
  end
  def self.add_database_entry_class(the_class,&blk)
	raise "This is not a class input is an instance of #{the_class.class}" unless the_class.is_a? Class
	#TODO: Add check for the ability to covert to and from a string	
	#TODO: Check that the block accepts the database and the key
	@database_entry_types = {} if @database_entry_types.nil? 
	@database_entry_types[the_class] = blk  
  end
  def self.[](the_class)
	return @database_entry_types[the_class] rescue nil
  end
#####################################
### General Setup ##################
self.add_database_entry_class(Class) { |ky| @db[ky].resolve }
self.add_database_entry_class(Symbol) { |ky| @db[ky] }
self.add_database_entry_class(String) { |ky| @db[ky].resolve }
##################################### 
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%######
### Database Variables   ###########
  attr_reader :db_parent # The owner of this Database object, if nil this is the Master Database 
  attr_reader :key	 # The Key for this database within the db_parent
  attr_reader :max_key	 # The total number of assigned keys (@max-key-1 is last assigned key) @max_key is next assignable key
#  attr_reader :db	 # The storage array for the database
  def db
	@db = {} if @db.nil?
	return @db
  end
  attr_reader :db_alive  # This is a status flag to prevent references from resolving dead pointers 
###################################
## Database Transactions ##########
# NOTE: All database transations should return self unless destructive 
  def add_to_db(input,key = nil)
  #TODO: Handle repeating a already selected key (raise an error or return nil?)
	the_key = (key.nil?) ? assign_key(input) : key
	@db[the_key] = input
	input.set_key(the_key,self) if Database.is_database?(input)
	return the_key
  end
  def remove_from_db(input)      # Should never be called by designer (use only for moving)
	if Database.is_database?(input)
		@db.delete(:"#{input.key}") 
		input.set_key(nil,nil)
	else
		@db.delete(find_key(input))
	end
	return self
  end
  def destroy_entry(input)	 # Destroys an object
	remove_from_db(input)
	input.destroy_self() if Database.is_database?(input)
  end
  def give_to_db(input,target_db) #gives an object owned by self to a target_db
	remove_from_db(input)
	target_db.add_to_db(input)
	return self
  end
  def move_self_to_db(target_db)
	@db_parent.remove_from_db(self) if Database.is_database?(@db_parent)
	target_db.add_to_db(self)
	return self
  end
  def delete_reference(input)
	@db.delete(input) if input.class <= String
	return self # TODO: Should this return the deleted object (like shift and pop would)?
  end
###################################################################
# Reference control functions
	def add_reference(key,collection,blk = nil)
	# A reference is added as a chain of object keys. it is stored as chain of keys strating from any database
	# 
		raise "Invalid key type. Key for Reference should be of type String, key is a #{key.class}" unless key.class <= String && key.to_i.to_s != key

		#@db[key] = Reference.new(self,collection,true,blk) 
		add_to_db Reference.new(self,collection,true,blk) , key
		
	end
	def add_reference_chain(key,chain,blk = nil)
		raise "Invalid key type. Key for Reference should be of type String, key is a #{key.class}" unless key.class <= String && key.to_i.to_s != key
		#@db[key] = Reference.new(self,chain,false,blk) 
		add_to_db Reference.new(self,chain,false,blk),key 

	end
#
###################################################################
###################################################################
# Instance db control functions
 def db_empty?
	return @db.empty? rescue return true
 end
 def db_alive?
	return @db_alive
 end 
 def init_database(parent = nil)
	parent.add_to_db(self) unless parent.nil?
	@db = Hash.new()
	@max_key = 0
	@db_alive = true
  end
  def destroy_record_of_self()
  # Destroy the record of one's self in the containing db
  	db_parent.remove_from_db(self)
	return self
  end
  def destroy_self
	destroy_record_of_self
	@db_alive = false
	for_each_instance { |x| x.destroy_self }
	return nil
  end
###################################################################
# General DB lookup functions
###################################################################
### Key Management functions ########################
  def assign_key(input)
	@max_key = @max_key + 1
	return :"#{@max_key-1}"
  rescue 
	init_database
	retry
  end
  def set_key(key_val,parent)
	@key = key_val
	@db_parent = parent
  end
  def find_if(&blk)
	for_each_db_entry { |v| return v if yield v } 
	return nil
  end
  def find_key(input)   
  # Find key assumes that if your calling this input is 
  # not a database (though it will work if it is its just slow)
  # This function does object_id comparisons not equality so 
  # It will fail on find_key("mark") even if there is a "mark" in the db 
	db.each_pair { |k,val|	return k if val.object_id == input.object_id }
	return nil
  end
  def [](ky)
	return instance_exec ky, &Database[ky.class]
  end
###################################################################
  def for_each_db_entry(&blk)
	db.each_value{|v| yield v if !v.nil?}
  end
  def for_each_instance(&blk)
	db.each_value{|v| yield v if !v.nil? && Database.is_database?(v)}
  end
  def for_each_data(&blk)
	db.each_value{|v| yield v unless !v.nil? && !Database.is_database?(v)}
  end
  def db_dump?()
	return true;
  end
  def write_db(file)
	file << db_dump()
  end
  def db_dump()
  # db_dump:
  # Returns the dump of this instances context as a REXML::Element
  # Recursivly adds the sub data and instances in the context
	this_db = REXML::Element.new 'instance'
	this_db.add_attribute('type','local');
	this_db.add_attribute('class',"#{self.class}");
	this_db.add_attribute('key',"#{self.key}");
	for_each_data do |d|
		this_db.add_element(d.to_s) if Database.is_data?(d)
	#Database.convert_to_data(d)
	end
	for_each_instance do |i|
		this_db.add_element(i.db_dump) if i.db_dump?()
	end	
	return this_db;
  end
end
