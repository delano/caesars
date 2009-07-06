
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

  VERSION = "0.8.0"
  
  HASH_TYPE = (RUBY_VERSION =~ /1.9/) ? ::Hash : Caesars::OrderedHash
  DIGEST_TYPE = Digest::SHA1
  
  require 'caesars/hash'
  
  @@debug = false
  @@caesars_tree = {}
  @@caesars_tree_pointer = []
  @@known_symbols = []
  @@known_symbols_by_glass = {}
  
  
    # An instance of Caesars::Hash which contains the data specified by your DSL
  attr_accessor :caesars_properties
  
  def initialize(name=nil)
    @caesars_name = name if name
    @caesars_properties = Caesars::Hash.new
    @caesars_pointer = @caesars_properties
    init if respond_to?(:init)
  end
  
  # Returns an array of the available top-level attributes
  def keys; @caesars_properties.keys; end
  
  # Returns the parsed tree as a regular hash (instead of a Caesars::Hash)
  def to_hash; @caesars_properties.to_hash; end
  
  def ld(*msg)
    self.class.ld *msg
  end
  
  def hash_parser
    
  end
  
  # This method handles all of the attributes that are not forced hashes
  # It's used in the DSL for handling attributes dyanamically (that weren't defined
  # previously) and also in subclasses of Caesars for returning the appropriate
  # attribute values. 
  def method_missing(meth, *args, &b)
    ld "Caesars.method_missing: #{meth}"
    add_known_symbol(meth)
    if Caesars.forced_ignore?(meth)
      ld "Forced ignore: #{meth}"
      return
    end
    
    # Handle the setter, attribute=
    if meth.to_s =~ /=$/ && @caesars_properties.has_key?(meth.to_s.chop.to_sym)
      return @caesars_properties[meth.to_s.chop.to_sym] = (args.size == 1) ? args.first : args
    end
    
    return @caesars_properties[meth] if @caesars_properties.has_key?(meth) && args.empty? && b.nil?
    
    # We there are no args and no block, we return nil. This is useful
    # for calls to methods on a Caesars::Hash object that don't have a
    # value (so we cam treat self[:someval] the same as self.someval).
    return nil if args.empty? && b.nil?

    
    if b

    # We've seen this attribute before, add the value to the existing element    
    elsif @caesars_pointer.kind_of?(Hash) && @caesars_pointer.has_key?(meth)
      
      # Make the element an Array once there's more than a single value
      unless @caesars_pointer[meth].is_a?(Array)
        @caesars_pointer[meth] = [@caesars_pointer[meth]] 
      end
      @caesars_pointer[meth] += args
    
      
    elsif !args.empty?
      @caesars_pointer[meth] = args.size == 1 ? args.first : args
    end
  
  end
  
  
  
  
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
  def self.inherited(modname)
    ld "INHERITED: #{modname}"
    
    # NOTE: We may be able to replace this without an eval using Module.nesting
    meth = Caesars.normalize_glass modname  # Some::HighBall => highball
    
    # The method name "meth" is now a known symbol 
    # for the short class name (also "meth").
    Caesars.add_known_symbol(modname, meth)
    
    # We execute a module_eval from the namespace of the inherited class  
    # so when we define the new module DSL it will be Some::HighBall::DSL.
    modname.module_eval %Q{
      module DSL
        def #{meth}(*args, &b)
          Caesars.ld "DSL: #{meth} (\#{args.inspect})"
          name = !args.empty? ? args.first.to_s : nil
          varname = "@#{meth.to_s}"
          varname << "_\#{name}" if name
          inst = instance_variable_get(varname)
          
          # When the top level DSL method is called without a block
          # it will return the appropriate instance variable name
          return inst if b.nil?
          p [:poop, Module.nesting[1], name, inst, varname]
          # Add to existing instance, if it exists. Otherwise create one anew.
          # NOTE: Module.nesting[1] == modname (e.g. Some::HighBall)
          inst = instance_variable_set(varname, inst || Module.nesting[1].new)
        #  inst.instance_eval(&b)
        #  inst
        end
        
        def self.methname
          :"#{meth}"
        end
        
      end
    }, __FILE__, __LINE__
    
  end
  
  def self.method_missing(meth, *args, &block)
    ld "METHOD MISSING: #{meth}"
    @@caesars_tree_pointer << self if @@caesars_tree_pointer.empty?
    type = args.first
    if type.nil?
      type = block.nil? ? String : Hash
    end
    full_meth = caesars_tree_pointer_name meth
    ld "#{self}: #{full_meth}: #{type}"
    
    @@caesars_tree[full_meth] = {
      :type => type,
      :parser => ''
    }
    unless block.nil?
      type = Hash unless block.nil?
      @@caesars_tree_pointer.push meth
      block.call
      @@caesars_tree_pointer.pop
    end
    @@caesars_tree_pointer.pop
  end
  
  def self.caesars_tree; @@caesars_tree; end
    
  def self.caesars_tree_pointer_name(meth)
    @@caesars_tree_pointer.empty? ? meth : [@@caesars_tree_pointer, meth].join('_')
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
    
  end
  
  
  class Scalar
    
  end
  
end