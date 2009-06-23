
class Caesars
  # = Caesars::Hash
  #
  # A subclass of ::Hash (1.9) or Caesars::OrderedHash (1.8) that provides
  # method names for hash parameters. It's like a lightweight OpenStruct. 
  #
  #     ch = Caesars::Hash[:tabasco => :lots!]
  #     puts ch.tabasco  # => lots!
  #
  class Hash < HASH_TYPE
    
    def method_missing(meth)
      STDERR.puts "Caesars::Hash.method_missing: #{meth}" if Caesars.debug?
      self[meth] || self[meth.to_s]
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
    
    def __class__
      HASH_TYPE
    end
    

    ##def githash(s)
    ##  # http://stackoverflow.com/questions/552659/assigning-git-sha1s-without-git
    ##  # http://github.com/mojombo/grit/blob/master/lib/grit/git-ruby/git_object.rb#L81
    ##  # http://github.com/mojombo/grit/blob/master/lib/grit/git-ruby/git_object.rb#L225
    ##  # http://www.kernel.org/pub/software/scm/git-core/docs/git-hash-object.html
    ##  # $ git hash-object file
    ##  DIGEST_TYPE.hexdigest(("%s %d\0" % ['blob', s.length]) << s)
    ##end
  end
end
