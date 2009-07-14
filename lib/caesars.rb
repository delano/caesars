require 'attic'
require 'openssl'

class Caesars
  extend Attic
  
  VERSION = "0.8.0".freeze
  DIGEST_TYPE = Digest::SHA1
  
  require 'caesars/hash'
  require 'caesars/glass'
  
  attic :caesars_properties
  
  
  
  def self.inherited(glass)
    ld "self.inherited: Creating #{glass}::DSL"
    meth = Caesars.normalize_glass(glass)
    glass.module_eval %Q{
      module DSL
        def #{meth}(*args, &b)
          name = !args.empty? ? args.first.to_s : nil
          varname = "@#{meth.to_s}"
          varname << "_\#{name}" if name
          inst = instance_variable_get(varname)
          
          # When the top level DSL method is called without a block
          # it will return the appropriate instance variable name
          return inst if b.nil?
          
          # Add to existing instance, if it exists. Otherwise create one anew.
          # NOTE: Module.nesting[1] == modname (e.g. Some::HighBall)
          inst = instance_variable_set(varname, inst || Module.nesting[1].new)
          inst.instance_eval(&b)
          inst
        end
        
        def self.methname
          :"#{meth}"
        end
        
      end
    }
  end
  
  
  def self.method_missing(meth, *args, &block)
    glass = self
    ld "self.method_missing: Creating #{glass}::#{meth}"
    name = meth.to_s.capitalize
    
    if block.nil?
      glass.meta_def meth do
        p 11111
      end
    else
      #glass.const_set name, Class.new do
      ##  
      #end
    end
    
  end
  
  
  
  
  
  
  # Returns the lowercase name of +klass+. i.e. Some::Taste  # => taste
  def Caesars.normalize_glass(g); (g.to_s.split(/::/)).last.downcase.to_sym; end
  
  @@debug = false
  def Caesars.enable_debug; @@debug = true; end
  def Caesars.disable_debug; @@debug = false; end
  def Caesars.debug?; @@debug; end
  
  def Caesars.ld(*msgs)
    return unless Caesars.debug?
    STDERR.puts msgs.collect { |m| "D: #{m}" }
  end
  
end

