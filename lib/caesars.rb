
# Caesars -- Rapid DSL prototyping in Ruby.
#
# Subclass Caesars and start drinking! I mean, start prototyping
# your own domain specific language!
#
# See bin/example
#
class Caesars

  require 'caesars/orderedhash'
  require 'caesars/exceptions'
  require 'caesars/config'
  require 'caesars/glass'

  VERSION = "0.8.0"
  
  HASH_TYPE = (RUBY_VERSION =~ /1.9/) ? ::Hash : Caesars::OrderedHash
  DIGEST_TYPE = Digest::SHA1
  
  require 'caesars/hash'
  
  @@debug = false
  @@caesars_tree = Caesars::Hash.new
  @@caesars_flat = {}
  @@caesars_parser_depth = []
  @@caesars_tree_pointer = @@caesars_tree
  @@known_symbols = []
  @@known_symbols_by_glass = {}
  
  def Caesars.enable_debug; @@debug = true; end
  def Caesars.disable_debug; @@debug = false; end
  def Caesars.debug?; @@debug; end
  
  # Add +s+ to the list of global symbols (across all instances of Caesars)
  def Caesars.add_known_symbol(g, s)
    g = Caesars.normalize_glass(g)
    STDERR.puts "add_symbol: #{g} => #{s}" if Caesars.debug?
    @@known_symbols << s.to_sym
    @@known_symbols_by_glass[g] ||= []
    @@known_symbols_by_glass[g] << s.to_sym
  end
  
  # Is +s+ in the global keyword list? (accross all instances of Caesars)
  def Caesars.known_symbol?(s); @@known_symbols.member?(s.to_sym); end
  
  # Is +s+ in the keyword list for glass +g+?
  def Caesars.known_symbol_by_glass?(g, s)
    g &&= g.to_sym
    @@known_symbols_by_glass[g] ||= []
    @@known_symbols_by_glass[g].member?(s.to_sym)
  end
  
  # Returns the lowercase name of +klass+. i.e. Some::Taste  # => taste
  def Caesars.normalize_glass(g); (g.to_s.split(/::/)).last.downcase.to_sym; end
  
  # Executes automatically when Caesars is subclassed. This creates the
  # YourClass::DSL module which contains a single method named after YourClass 
  # that is used to catch the top level DSL method. 
  #
  # For example, if your class is called Glasses::HighBall, your top level method
  # would be: highball.
  #
  #      highball :mine do
  #        volume "9oz"
  #      end
  #
  def Caesars.inherited(modname)
    ld "INHERITED: #{modname}"
    
    # NOTE: We may be able to replace this without an eval using Module.nesting
    meth = Caesars.normalize_glass modname  # Some::HighBall => highball
    
    # The method name "meth" is now a known symbol 
    Caesars.add_known_symbol modname, meth
    
    modname.module_eval do
      include Caesars::Glass
    end
    
    # We execute a module_eval form the namespace of the inherited class  
    # so when we define the new module DSL it will be Some::HighBall::DSL.
    modname.module_eval %Q{
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
          inst = instance_variable_set(varname, inst || Module.nesting[1].new(name))
          inst.instance_eval(&b)
          inst
        end
        
        def self.methname
          :"#{meth}"
        end
        
      end
    }, __FILE__, __LINE__
    
  end
  
  def self.method_missing(meth, *args, &block)
    ld "CLASS METHOD MISSING: #{meth}"
    
    # When parsing the class definition DSL, this 
    # Array will contain the current block depth. 
    @@caesars_parser_depth << self if @@caesars_parser_depth.empty?
    
    klass = args.shift
    if klass.nil?
      klass = block.nil? ? String : Hash
    end
    
    raise "Bad class (#{klass}) for #{meth}" unless klass.is_a? Class
    
    modifiers = args
    
    if modifiers.member? :global
      full_meth = caesars_parser_global_name meth
    else
      full_meth = caesars_parser_depth_name meth
    end
    
    ld "#{self}: #{full_meth}: #{klass}: #{modifiers}"
    
    @@caesars_tree[meth] ||= Caesars::Hash.new
    @@caesars_flat[full_meth] = {
      :klass => klass
    }
    
    prev = @@caesars_tree_pointer
    @@caesars_tree_pointer = @@caesars_tree[meth]
    
    unless block.nil?
      @@caesars_parser_depth.push meth
      block.call
      @@caesars_parser_depth.pop
    end
    
    @@caesars_tree_pointer = prev
    
    # It's important to remove the class name in the event we'll be
    # parsing more than one DSL (e.g. when using Caesars::Config).
    @@caesars_parser_depth.pop
  end
  
  def Caesars.known_method?(m)
    is_regular_method = @@caesars_flat.has_key? m

    is_regular_method #|| is_global_method
  end
  
  def Caesars.get_method_klass(m)
    known_method?(m) ? @@caesars_flat[m][:klass] : nil
  end
  
  def self.caesars_flat; @@caesars_flat; end
    
  def self.caesars_parser_depth_name(meth)
    @@caesars_parser_depth.empty? ? meth : [@@caesars_parser_depth, meth].join('_')
  end
  
  # available to an entire glass regardless of depth
  def self.caesars_parser_global_name(meth)
    [self, '_global', meth].join('_')
  end

  def self.ld(*msg)
    STDERR.puts msg.collect { |v| "D: #{v}"} if Caesars.debug?
  end
  
  
  # Specify a method that should always be ignored. 
  # Here's an example:
  #
  #     class Food < Caesars
  #       taste Ignore
  #     end
  #     
  #     food do
  #       taste :delicious
  #     end
  #
  #     @food.taste             # => nil
  #
  class Ignore
    ALLOW_BLOCK = true   # No need to raise a fuss, we ignore it anyway
    STORE_BLOCK = false
  end
  
  
  class Scalar
    ALLOW_BLOCK = false
    STORE_BLOCK = false
  end
  
  class Proc
    ALLOW_BLOCK = true
    STORE_BLOCK = true
  end
  
  class Array
    ALLOW_BLOCK = false
    STORE_BLOCK = false
  end
  
end