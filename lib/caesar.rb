
# Caesar -- A simple class for rapid DSL prototyping.
#
# Subclass Caesar, then tell it which attributes have children using
# Caesar.bloody and which have blocks that you want to execute later
# using Caesar.virgin. That's it! Just start drinking! I mean, start 
# writing your domain specific language!
#
# See README.rdoc for a usage example.
#
class Caesar
  VERSION = "0.3.1"
  # A subclass of ::Hash that provides method names for hash parameters.
  # It's like a lightweight OpenStruct. 
  #     ch = Caesar::Hash[:tabasco => :lots!]
  #     puts ch.tabasco  # => lots!
  #
  class Hash < ::Hash
    def method_missing(meth)
      (self.has_key?(meth)) ? self[meth] : nil
    end
  end
    # An instance of Caesar::Hash which contains the data specified by your DSL
  attr_accessor :caesar_properties
  # Creates an instance of Caesar. 
  # +name+ is . 
  def initialize(name=nil)
    @caesar_name = name if name
    @caesar_properties = Caesar::Hash.new
    @caesar_pointer = @caesar_properties
  end
  # This method handles all of the attributes that do not contain blocks. 
  def method_missing(name, *args, &b)
    return @caesar_properties[name] if @caesar_properties.has_key?(name) && args.empty? && b.nil?
    if @caesar_pointer[name]
      @caesar_pointer[name] = [@caesar_pointer[name]] unless @caesar_pointer[name].is_a?(Array)
      @caesar_pointer[name] += args
    elsif !args.empty?
      @caesar_pointer[name] = args.size == 1 ? args.first : args
    end
  end
  # see bin/example for usage.
  def self.virgin(meth)
    self.bloody(meth, false)
  end
  # see bin/example for usage.
  def self.bloody(meth, execute=true)
    define_method(meth) do |*names,&b|  # |*names,&b| syntax does not parse in Ruby 1.8
      all = instance_variable_get("@" << meth.to_s) || []
      
      names.each do |name|
        instance_variable_set("@" << meth.to_s, all << name)
        
        if execute
          prev = @caesar_pointer
          @caesar_pointer[name] ||= Caesar::Hash.new
          @caesar_pointer = @caesar_pointer[name]
          b.call if b
          @caesar_pointer = prev
        else
          @caesar_pointer[name] = b
        end
        
      end
      nil
    end
    define_method("#{meth}_values") do ||
      instance_variable_get("@" << meth.to_s) || []
    end
  end
  # Executes automatically when Caesar is subclassed. This creates the
  # YourClass::DSL module which contains a single method: method_missing. 
  # This is used to catch the top level DSL method. That's why you can 
  # used any method name you like. 
  def self.inherited(modname)
    module_eval %Q{
      module #{modname}::DSL
        def method_missing(meth, *args, &b)
          raise NameError.new("undefined local variable or method \#{meth} in #{modname}") if args.empty? && b.nil?
          name = !args.empty? ? args.first.to_s : nil
          varname = "@\#{meth.to_s}"
          varname << "_\#{name}" if name
          i = instance_variable_set(varname, #{modname.to_s}.new(name))
          i.instance_eval(&b) if b
          i
        end
      end
    }
  end
end





