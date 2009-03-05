
# Caesars -- A simple class for rapid DSL prototyping.
#
# Subclass Caesars and start drinking! I mean, start prototyping
# your own domain specific language!
#
# See bin/example
#
class Caesars
  VERSION = "0.3.2"
  # A subclass of ::Hash that provides method names for hash parameters.
  # It's like a lightweight OpenStruct. 
  #     ch = Caesars::Hash[:tabasco => :lots!]
  #     puts ch.tabasco  # => lots!
  #
  class Hash < ::Hash
    def method_missing(meth)
      (self.has_key?(meth)) ? self[meth] : nil
    end
  end
    # An instance of Caesars::Hash which contains the data specified by your DSL
  attr_accessor :caesars_properties
  # Creates an instance of Caesars. 
  # +name+ is . 
  def initialize(name=nil)
    @caesars_name = name if name
    @caesars_properties = Caesars::Hash.new
    @caesars_pointer = @caesars_properties
  end
  # This method handles all of the attributes that do not contain blocks. 
  def method_missing(name, *args, &b)
    return @caesars_properties[name] if @caesars_properties.has_key?(name) && args.empty? && b.nil?
    if @caesars_pointer[name]
      @caesars_pointer[name] = [@caesars_pointer[name]] unless @caesars_pointer[name].is_a?(Array)
      @caesars_pointer[name] += args
    elsif !args.empty?
      @caesars_pointer[name] = args.size == 1 ? args.first : args
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
          prev = @caesars_pointer
          @caesars_pointer[name] ||= Caesars::Hash.new
          @caesars_pointer = @caesars_pointer[name]
          b.call if b
          @caesars_pointer = prev
        else
          @caesars_pointer[name] = b
        end
        
      end
      nil
    end
    define_method("#{meth}_values") do ||
      instance_variable_get("@" << meth.to_s) || []
    end
  end
  # Executes automatically when Caesars is subclassed. This creates the
  # YourClass::DSL module which contains a single method named after YourClass 
  # that is used to catch the top level DSL method. 
  #
  # For example, if your class is called Glasses::HighBall, your top level method
  # would be: highball.
  #
  #      highball :mine do
  #        volume 9.oz
  #      end
  #
  def self.inherited(modname)
    meth = (modname.to_s.split(/::/))[-1].downcase  # Some::ClassName => classname
    module_eval %Q{
      module #{modname}::DSL
        def #{meth}(*args, &b)
          name = !args.empty? ? args.first.to_s : nil
          varname = "@#{meth.to_s}"
          varname << "_\#{name}" if name
          i = instance_variable_set(varname, #{modname.to_s}.new(name))
          i.instance_eval(&b) if b
          i
        end
      end
    }, __FILE__, __LINE__
  end
end





