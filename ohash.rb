# Defines class OHash, which is identical to Hash, but insertion-ordered.

if RUBY_VERSION < 1.9
	class OHash
		def initialize *a,&b
			@hash = Hash.new(*a,&b)
			@idxs = {}
			@keys = []
			@vals = []
			@list = []
		end
		def OHash.[] *a
			ohash = new OHash
			if a.length == 1
				a.first.each{|k,v| ohash[k] = v }
			else
				raise ArgumentError 'odd number of arguments for OHash' if a.length % 2 != 0
				a.each_slice(2){|k,v| ohash[k] = v }
			end
			ohash
		end
		def == o
			@hash == o
		end
		def [] k
			@hash[k]
		end
		def []= k, v
			if i = @idxs[k]
				@list[i][1] = v
				@vals[i]    = v
			else
				@idxs[k] = @list.length
				@list << [k,v]
				@keys << k
				@vals << v
			end
			@hash[k] = v
		end
		alias :[]= :store
		def clear
			@hash = {}
			@idxs = {}
			@list = []
			@vals = []
			@keys = []
		end
		def default k=nil
			@hash.default k
		end
		def default= o
			@hash.default= o
		end
		def default_proc
			@hash.default_proc
		end
		def delete k, &b
			if i = @idxs[k]
				@idxs.delete i
				@list.delete_at i
				@vals.delete_at i
				@keys.delete_at i
				@hash.delete k
			else
				b ? yield k : nil
			end
		end
		def delete_if &b
			@list.each do |k,v|
				if yield k,v
					delete k
				end
			end
			self
		end
		def each &b
			@list.each &b
			self
		end
		def each_key &b
			@keys.each &b
			self
		end
		def each_pair &b
			@list.each{|a| yield a[0],a[1] }
			self
		end
		def each_value &b
			@vals.each &b
			self
		end
		def empty?
			@list.empty?
		end
		def eql? o
			@hash.eql? o
		end
		def fetch k, *r &b
			@hash.fetch k, *r, &b
		end
		def has_key? k
			@hash.has_key? k
		end
		alias :has_key? :include?
		alias :has_key? :key?
		alias :has_key? :member?
		def has_value? v
			@hash.has_value? v
		end
		alias :has_value? :value?
		def hash
			@list.hash
		end
		def index v
			@hash.index v
		end
		#def indexes *k; end
		#alias :indexes :indices
		def inspect
			"{#{@list.map{|k,v|"#{k.inspect}=>#{v.inspect}"}.join ', '}}"
		end
		def invert
			list = @list
			clear
			list.each{|k,v| store v, k }
			self
		end
		def keys
			@keys.dup
		end
		def length
			@list.length
		end
		alias :length :size
		def merge hsh, &b
			dup.merge! hsh, &b
		end
		def merge! hsh, &b
			hsh.each do |k,v|
				if i = @idxs[k]
					v = yield k,@hash[k],v if b
				end
				self[k] = v
			end
		end
		alias :merge! :update
		def rehash
			@hash.rehash
			self
		end
		def reject &b
			dup.delete_if &b
		end
		def reject! &b
			n = @list.length
			delete_if &b
			self unless @list.length == n
		end
		def replace hsh
			clear
			hsh.each{|k,v| store k, v }
			self
		end
		def select &b
			@list.select &b
		end
		def shift
			if @list.empty?
				@hash.default
			else
				k = @keys.shift
				@idxs.delete k
				@hash.delete k
				@vals.shift
				@list.shift
			end
		end
		def sort &b
			@list.sort &b
		end
		def to_a
			@list.dup
		end
		def to_hash
			self
		end
		def to_s
			@list.join
		end
		def values
			@vals.dup
		end
		def values_at *a
			@hash.values_at *a
		end
	end
else
	OHash = Hash
end

