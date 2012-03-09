class Dictionary
# The dictionary module provides hooks to orgainze and store class data
# in an interface that allows modifiable indexing methods to streamline 
# the conceptual process of storing data Dictionaries can be used to 
# organize class hierarchy store a complex array or provide a obfuscation
# API for file access.

# Dictionary creation API is integrated into Generic (EDIT: Is this for sure?)
	def initialize
		@ent = Array.new	# list of entries
		@entdef = Array.new	# def coreesponding to the entry
		@def2ent = Hash.new	# Allows translation from def => entires
		@fi = [0]		# The list of free indicies
		@ao = []		# order of items added
	end
	def add_entry(item,*args)
		i = @fi.pop	# pick an open slot
		@ent[i] = item	# put it in the slot
		@ao.push i	# add it to the addition order
		# populate the definition entries
		args = [] if args.nil?
		args.each do |a|
			unless a.is_a String or a.is_a Symbol
			throw "Attempted to add a definition to a #{self.class} that is not a String or Hash"
			end
		end
		@entdef[i] = args
		@entdef[i].each do |d|
			@def2ent[d] = [] if @def2ent[d].nil?
			@def2ent[d].push i
		end
		@fi << @ent.length() if @fi.empty?
	end
	def add_entries(items,defs)
		# Assumes an Array of items and a corresponding list of defs item[i] goes with def[i]
		items.each do |it|
			if defs[i].nil?
				add_entry(it)
			else
				eval("self.add_entry(it,#{defs[i].join(",")})")
			end
		end

	end
	def delete_at(index)
		@ent[index] = nil
		@entdef[index].each {|d| @def2ent[d].delete(index); @def2ent.delete(d) if @def2ent[d].empty?}
		@fi.push index
		@ao.delete index
	end
	def delete(obj)	# deletes all references to an object
		@ent.each_index do |i|
			delete_at(i) if @ent[i].equal?(obj) and !@ent[i].nil?
		end
	end
end
module Iterator
# the Iterator class is the ordered access interface for a dictionary
end
