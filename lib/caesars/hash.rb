
# A subclass of ::Hash that provides method names for hash parameters.
# It's like a lightweight OpenStruct. 
#     ch = Caesars::Hash[:tabasco => :lots!]
#     puts ch.tabasco  # => lots!
#
class Caesars
  class Hash < HASH_TYPE
    def method_missing(meth)
      self[meth] if self.has_key?(meth)
    end

    # Returns a clone of itself and all children cast as ::Hash objects
    def to_hash(hash=self)
      return hash unless hash.is_a?(Caesars::Hash) # nothing to do
      target = (Caesars::HASH_TYPE)[dup]
      hash.keys.each do |key|
        if hash[key].is_a? Caesars::Hash
          target[key] = hash[key].to_hash
          next
        elsif hash[key].is_a? Array
          target[key] = hash[key].collect { |h| to_hash(h) }  
          next
        end
        target[key] = hash[key]
      end
      target
    end

  end
end
