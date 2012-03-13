class Dictionary
# The dictionary module provides hooks to orgainze and store class data
# in an interface that allows modifiable indexing methods to streamline 
# the conceptual process of storing data Dictionaries can be used to 
# organize class hierarchy store a complex array or provide a obfuscation
# API for file access.

# Dictionary creation API is integrated into Generic (EDIT: Is this for sure?)
	attr_reader :iter
	attr_writer :iter
	def initialize
		@ent = Array.new	# list of entries
		@entdef = Array.new	# def coresponding to the entry
		@def2ent = Hash.new	# Allows translation from def => entires
		@fi = [0]		# The list of free indicies
		@ao = []		# order of items added
		@iter = nil		# default iterator
		#@hookin = []		# add hook
		#@hookout = []		# delete hook
		return self
	end
	def clear
		initialize
	end
	def add_entry(item,*args)
		i = @fi.pop	# pick an open slot
		@ent[i] = item	# put it in the slot
		@ao.push i	# add it to the addition order
		# populate the definition entries
		args = [] if args.nil?
		args.each do |a|
			unless a.kind_of? String or a.kind_of? Symbol
				raise "Attempted to add a definition to a #{self.class} that is not a String or Hash"
			end
		end
		@entdef[i] = args
		@entdef[i].each do |d|
			@def2ent[d] = [] if @def2ent[d].nil?
			@def2ent[d].push i
		end
		@fi << @ent.length() if @fi.empty?
		iter.update! unless iter.nil?
		return item
	end
	def <<(input)
		if input.kind_of? Array
			add_entries input
		else
			add_entry input
		end
	end
	def add_entries(items,defs = [])
		# Assumes an Array of items and a corresponding list of defs item[i] goes with def[i]
		items.each do |it|
			if defs[i].nil?
				add_entry(it)
			else
				eval("self.add_entry(it,#{defs[i].join(",")})")
			end
		end
	end
	def list
		return @ent.compact
	end
	def delete_at(index)
		out = @ent[index]
		@ent[index] = nil
		@entdef[index].each {|d| @def2ent[d].delete(index); @def2ent.delete(d) if @def2ent[d].empty?}
		@fi.push index
		@ao.delete index
		iter.update! unless iter.nil?
		return out
	end
	def delete(obj)	# deletes all references to an object
		@ent.each_index do |i|
			delete_at(i) if @ent[i].equal?(obj) and !@ent[i].nil?
		end
	end
	def each(iter = nil,&blk)
		@ao.each{|i| yield(@ent[i])} if iter.nil?
		iter.each{|i| yield(i)} unless iter.nil?
		return self
	end
	def each_index(iter = nil,&blk)
		@ao.each{|i| yield(i)} if iter.nil?
		iter.each_index{|i| yield(i)} unless iter.nil?
		return self
	end
	def each_pair(iter = nil,&blk) # returned the definition list for an entry
		each_index do|i|
			yield @ent[i],@entdef[i]
		end if iter.nil?
		iter.each_index do|i|
			yield @ent[i],@entdef[i]
		end unless iter.nil?
		return self
	end
	def each_key(&blk) # returned the definition list for an entry
		@def2ent.each_key {|i| yeild(i)}
		return self
	end
	def add_order
		return @ao
	end
	def to_ary
		return @ent.compact
	end
	def &(dict)
		return list & dict.list
	end
	def |(dict)
		return list | dict.list
	end
	def concat(dict)
		dict.each_pair{|e,d| add_entry(e,d)}
	end
	def has_key?(input)
		return not(@def2ent[input].nil? && @def2ent[input].empty?)
	end
	def to_s
		out = "\#{Dictionary:"
		each_pair do |e,d|
			out << "#{e.class} => [#{d.join(",")}] "
		end
		return out << "}"
	end
	def inspect
		return "#{self.class}"
	end
	def [](f,l = nil)
		out = []
		case f
			when Fixnum then
				return at(f) if l.nil?
				return self[((f)..(l))]
			when Range then
				return nil if @ao[f].nil?
				@ao[f].each{|i| out.push(at(i))}
			when Symbol then
				return value(f)
			when String then
				return value(f)
			when Array then
				f.each{|i| out.push(at(i))}
			else 
				return at(f.to_i)
		end
		return out
	end
	def []=(*args)
		raise "Dictionary Entries cannot be set. Use the add_entry or delete_entry function"
	end
	def at(i)
		return nil if @ao[i].nil?
		return @ent[@ao[i]]
	rescue
		raise "Incorrect Indexing of #{self.class} indexed with #{i.class}"
	end
	def values(k)
		return nil if @def2ent[k].nil?
		return nil if @def2ent[k].empty?
		return self.[](@def2ent[k])
	rescue
		raise "Incorrect Hash Access of #{self.class} indexed with #{k.class}"
	end
	class Iterator
	# the Iterator class is the ordered access interface for a dictionary
	# various access models 
		def initialize(dict)
			raise "Incorrect input class for #{self.class}" unless dict.kind_of? Dictionary
			@dict = dict
			@list = [0..(dict.add_order.length()-1)].to_ary
			@ptr = -1
			@mode = :ll
			return self
		end
		def fwd
			return End if @list.length() == (@ptr-1)
			@ptr += 1
			return @dict[@list[@ptr]]
		end
		def fwdi
			return End if @list.length() == (@ptr-1)
			@ptr += 1
			return @list[@ptr]
		end
		def finish?
			return true if @ptr == (@list.length()-1)
			return false
		end
		def rev
			return Start if @ptr == 0
			@ptr -= 1
			return @dict[@list[@ptr]]
		end
		def revi
			return Start if @ptr == 0
			@ptr -= 1
			return @list[@ptr]
		end
		def start?
			return true if @ptr == -1 or @ptr == 0
			return false
		end
		def update!
			@list = @dict.add_order
			@ptr = -1
			return self
		end
		class Start
		end
		class End
		end
	end
end
