
# Caesar -- A simple class for rapid DSL prototyping.
#
# Subclass Caesar, then tell it which attributes have children using
# Caesar.complex and which have blocks that you want to execute later.
# That's it! Just start drinking! I mean, start writing your domain 
# specific language!
#
# Usage:
#
#     class KitchenStaff < Caesar #:nodoc:
#       bloody :location				 # Has children
#       bloody :person           # This too
#       virgin :calculate        # Will store its block as a Proc
#     end
#     
#     extend KitchenStaff::DSL
#     
#     staff :fte do
#       holidays 0
#       location :splashdown do
#         town :tsawwassen
#         person :steve, :sheila do
#           role :manager
#         end
#         person :steve do
#           role :cook
#           anger :high
#           hours 25
#           catchphrase "Rah! [strokes goatee]"
#         end
#         person :sheila do
#           catchphrase "This gravy tastes like food I ate in a Mexican prison."
#           hours rand(20)
#           rate "9.35/h"
#           calculate :salary do |gumption|
#             "%.2f" % [gumption * self.splashdown.sheila.rate.to_f]
#           end
#         end
#         person :delano do
#           role :cook
#           rate "8.35/h"
#           hours 57
#           satisfaction :low
#           calculate :salary do 
#             self.splashdown.delano.rate.to_f * self.splashdown.delano.hours
#           end
#         end
#       end
#     end
#     
#     # The instance you create with the DSL becomes available via an instance variable
#     # in the same namespace. In this example we used "staff :fte" so the variable will be 
#     # called @staff_fte. Had we used "team :awesome", it would have been @team_awesome.
#
#     p @staff_fte.holidays           # => 0
#     p @staff_fte.splashdown.delano  # => {:role=>:cook, :rate=>"$8.35/h", :satisfaction=>:low}
#     p @staff_fte.splashdown.sheila  # => {:role=>:manager, :catchphrase=>"This gravy tastes like food I ate in a Mexican prison."}
#     p @staff_fte.splashdown.steve   # => {:role=>[:manager, :cook], :anger=>:high, :catchphrase=>"Rah! [strokes goatee]"}
#     p @staff_fte.location_values    # => [:splashdown]
#     p @staff_fte.calculate_values   # => [:salary, :salary]
#     p @staff_fte.person_values.uniq # => [:steve, :sheila, :delano, :angela]
#     p @staff_fte.splashdown.delano.satisfaction            # => :low
#     p @staff_fte.splashdown.delano.salary.call             # => 475.95
#     p @staff_fte.splashdown.sheila.salary.call(rand(100))  # => 549.77
#
class Caesar
  VERSION = 0.3
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
  def initialize(name)
    @caesar_name = name
    @caesar_properties = Caesar::Hash.new
    @caesar_pointer = @caesar_properties
  end
  def method_missing(name, *args, &b)
    return @caesar_properties[name] if @caesar_properties.has_key?(name) && args.empty? && b.nil?
    if @caesar_pointer[name]
      @caesar_pointer[name] = [@caesar_pointer[name]] unless @caesar_pointer[name].is_a?(Array)
      @caesar_pointer[name] += args
    elsif !args.empty?
      @caesar_pointer[name] = args.size == 1 ? args.first : args
    end
  end
  def self.virgin(meth)
    self.bloody(meth, false)
  end
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
  def self.inherited(modname)
    module_eval %Q{
      module #{modname}::DSL
        def method_missing(meth, *args, &b)
          raise NameError.new("undefined local variable or method \#{meth} in #{modname}") if args.empty? || b.nil?
          name = args.first
          i = instance_variable_set("@\#{meth.to_s}_\#{name}", #{modname.to_s}.new(name.to_s))
          i.instance_eval(&b) if b
          i
        end
      end
    }
  end
end





