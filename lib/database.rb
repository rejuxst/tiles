require 'config'
require 'pry'
require 'rexml/document'
require 'rexml/element'

#TODO: 
#	- Add private/public/protected db access
#	- Modify default setup for acceptabble key values (i.e exclude '#' from reference names to support equation)
#	- Add module level and instance level security protocols
#	- MAYBE switch to class inheritance model over module (most of the semantic associated with db suggest this)
#	- Deal with handling  save/loading with regards to configuration and initializiation.
#	- Adjust the semantic to allow for classes to be databases as well
#	- Allow for indexing with multiple values
module Database

### Making Database Configurable ###
  extend Tiles::Configurable
####################################

### Class Functions ################
  def self.read_db(xmlstring)	
  end
  def self.is_database?(input)
	(input.is_a? Class) ? input.is_database? : input.class.include?(Database) rescue return false
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
  def self.set_assign_key(&blk)
	@assign_key = blk
  end
  def self.assign_key
	@assign_key
  end
  def self.is_database_entry_class?(the_class)
	@database_entry_types.any?{|key,val| key == the_class}
  end
  def self.[](the_class)
	return @database_entry_types[the_class] rescue nil
  end
#####################################
configuration_method :add_database_entry_class, :set_assign_key
### General Setup ##################
#self.add_database_entry_class(Class) { |ky|  @db[ky].nil?() ? nil : @db[ky].resolve }
#self.add_database_entry_class(Symbol) { |ky| @db[ky] }
#self.add_database_entry_class(Fixnum) { |ky| @db[ky] }
#self.add_database_entry_class(String) do |ky| 
#self.set_assign_key do 
default_configuration_call(:add_database_entry_class,
		Class) { |ky|  @db[ky].nil?() ? nil : @db[ky].resolve }
default_configuration_call(:add_database_entry_class,
		Fixnum) { |ky| @db[ky] }
default_configuration_call(:add_database_entry_class,
		String) do |ky| 
	temp = @db[ky]
	(temp.is_a?(Reference)) ? temp.resolve : temp
end
default_configuration_call(:set_assign_key) do 
	@max_key = 0 if @max_key.nil?
	@max_key = @max_key + 1
end
##################################### 
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%######
### Database Variables   ###########
  attr_reader :db_parent # The owner of this Database object, if nil this is the Master Database 
  attr_reader :key	 # The Key for this database within the db_parent
  attr_reader :max_key	 # The total number of assigned keys (@max-key-1 is last assigned key) @max_key is next assignable key
  # The storage array for the database
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
#	input.each { |i| add_to_db(i) } if input.is_a? Array
	the_key = (key.nil?) ? assign_key(input) : key
	db[the_key] = input
	input.set_key(the_key,self) if Database.is_database?(input)
	return the_key
  end
  def remove_from_db(input)      # Should never be called by designer (use only for moving)
	if Database.is_database?(input)
		@db.delete(input.key) 
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
# Add Reference to an object
def add_reference(key,target,opts = {} ,&blk)
	unless key.class <= String && key.to_i.to_s != key
		raise "Invalid key type. Key for Reference should be of type String, key is a #{key.class}" 
	end
	add_reference_set(key,target,opts) if target.is_a? Array
	add_to_db(target) if opts[:add_then_reference]
	add_to_db Reference.new(self,target,:proc => blk) , key
end
# A reference is added as a chain of object keys. it is stored as chain of keys starting from any database 
def add_reference_chain(key,chain,&blk)
	unless key.class <= String && key.to_i.to_s != key
		raise "Invalid key type. Key for Reference should be of type String, key is a #{key.class}" 
	end
	add_to_db Reference::Chain.new(self,chain, :proc => blk) , key 
end
def add_reference_collection(key,target,opts = {},&blk)
	raise "Invalid target must be an array is a #{target.class}" unless target.is_a? Array
	add_to_db Reference::Collection.new(self,target,:proc => blk) , key
end
def add_reference_set(key,target,opts = {})
	unless key.class <= String && key.to_i.to_s != key
		raise "Invalid key type. Key for Reference should be of type String, key is a #{key.class}" 
	end
	target.each { |t| add_to_db t }  if opts[:add_then_reference]
	add_to_db Reference::Set.new(self,target) , key
end
def add_variable(key,target)
	unless key.class <= String && key.to_i.to_s != key
		raise "Invalid key type. Key for Reference should be of type String, key is a #{key.class}" 
	end
	add_to_db Reference::Variable.new(self,target) , key
	
end
#
###################################################################
###################################################################
# Instance db control functions
 def db_empty?
	return @db.empty? rescue return true
 end
 def db_alive?
	init_database if @db_alive.nil? #TODO: HIGH PRIORITY> Remove this line shouldn't be happening or should raise an error
	return @db_alive
 end 
 def in_this_db?(item) #TODO: Suppose multiple depth levels
	item.db_parent == self
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
	return instance_exec input, &Database.assign_key
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
  def db_get(ky)
	return instance_exec ky, &Database[ky.class]
  end
  def [](*ky)
	ky.inject(self){ |d,k| d.db_get(k) } rescue nil
  end
################## Missing Method #################################
  # Allows for dynamic declaration of singleton methods to access references
  # TODO: What happens when a reference is removed?
  # TODO: Make sure the base code relies on safe idioms
  def method_missing(method_sym, *arguments, &block)
	possible_output = self.db_get(method_sym.to_s)
	if !possible_output.nil? || db.has_key?(method_sym.to_s)
		define_singleton_method method_sym.to_sym, Proc.new() { self.db_get(method_sym.to_s) }
		self.db_get(method_sym.to_s)
	else
		super
	end

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
  def is_database?
	true
  end
############## Misc Functions ##################################
  def inspect
"#<#{self.class}:0x#{object_id.to_s(16)} | db: size(#{@db.length}) => References: #{@db.count{|ky,val| val.class <= Reference}}>"
  end

end
