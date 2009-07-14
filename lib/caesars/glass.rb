

class Caesars
  
  # = Caesars::Glass
  # 
  # These methods are intended to be included in the top-level 
  # DSL class. In the following example, "Machines" is the glass. 
  # 
  #     class Machines < Caesars
  #       
  #     end
  # 
  # You'll never need to use this module directly, but it's helpful
  # to know what methods are available to your top-level classes.
  #
  module Glass
    
      # An instance of Caesars::Hash which contains the data specified by your DSL
    attr_accessor :caesars_properties

    def initialize(name=nil)
      @caesars_name = name if name
      @caesars_pointer = @caesars_properties = Caesars::Hash.new
      @caesars_parser_depth = []
      init if respond_to?(:init)
    end

    # Returns an array of the available top-level attributes
    def keys; @caesars_properties.keys; end

    # Returns the parsed tree as a regular hash (instead of a Caesars::Hash)
    def to_hash; @caesars_properties.to_hash; end

    def ld(*msg)
      Caesars.ld *msg
    end
    
    # This method handles all of the attributes that are not forced hashes
    # It's used in the DSL for handling attributes dyanamically (that weren't defined
    # previously) and also in subclasses of Caesars for returning the appropriate
    # attribute values. 
    def method_missing(meth, *args, &b)
      # Handle the setter, attribute=
      meth.to_s.chop.to_sym if meth.to_s =~ /=$/
      
      @caesars_parser_depth << meth
      Caesars.add_known_symbol self.class, meth
      full_meth = self.caesars_parser_depth_name
      
      klass = Caesars.get_method_klass full_meth
      if klass.nil?
        klass = b.nil? ? Caesars::Scalar : Caesars::Hash
      end
      
      ld "METHOD MISSING: #{self}: #{full_meth}: #{klass}"
      
      return @caesars_properties[meth] if @caesars_properties.has_key?(meth) && args.empty? && b.nil?
      
      # We there are no args and no block, we return nil. This is useful
      # for calls to methods on a Caesars::Hash object that don't have a
      # value (so we cam treat self[:someval] the same as self.someval).
      return nil if args.empty? && b.nil?
      
      if b
        klass = Caesars::Hash if klass.nil?
        
        # We loop through each of the arguments sent to "meth". 
        # Elements are added for each of the arguments and the
        # contents of the block will be applied to each one. 
        # This is an important feature for Rudy configs since
        # it allows defining several environments, roles, etc
        # at the same time.
        #     env :dev, :stage, :prod do
        #       ...
        #     end
        
        # Use the name of the method if no name is supplied. 
        args << meth if args.empty?
        args.each do |name|
          prev = @caesars_pointer
          @caesars_pointer[name] ||= Caesars::Hash.new
          if klass::STORE_BLOCK
            @caesars_pointer[name] = b
          else
            @caesars_pointer = @caesars_pointer[name]
            begin
              b.call if b
            rescue ArgumentError, SyntaxError => ex
              STDERR.puts "CAESARS: error in #{meth} (#{args.join(', ')})" 
              raise ex
            end
            @caesars_pointer = prev
          end
        end
      elsif @caesars_pointer.kind_of?(Hash) && @caesars_pointer[meth]

        if klass.kind_of?(Array)
          @caesars_pointer[meth] ||= []
          @caesars_pointer[meth] << args
        else
          # Make the element an Array once there's more than a single value
          unless @caesars_pointer[meth].is_a?(Array)
            @caesars_pointer[meth] = [@caesars_pointer[meth]] 
          end
          @caesars_pointer[meth] += args
        end

      elsif !args.empty?
        if klass.kind_of?(Array)
          @caesars_pointer[meth] = [args]
        else
          @caesars_pointer[meth] = args.size == 1 ? args.first : args
        end
      end
        
      ##if b
      ##
      ### We've seen this attribute before, add the value to the existing element    
      ##elsif @caesars_pointer.kind_of?(Hash) && @caesars_pointer.has_key?(meth)
      ##  
      ##  # Make the element an Array once there's more than a single value
      ##  unless @caesars_pointer[meth].is_a?(Array)
      ##    @caesars_pointer[meth] = [@caesars_pointer[meth]] 
      ##  end
      ##  @caesars_pointer[meth] += args
      ##
      ##  
      ##elsif !args.empty?
      ##  @caesars_pointer[meth] = args.size == 1 ? args.first : args
      ##end
      
      @caesars_parser_depth.pop

    end

    # instance_exec for Ruby 1.8 written by Mauricio Fernandez
    # http://eigenclass.org/hiki/instance_exec
    if RUBY_VERSION =~ /1.8/
      module InstanceExecHelper; end
      include InstanceExecHelper
      def instance_exec(*args, &block) # !> method redefined; discarding old instance_exec
        mname = "__instance_exec_#{Thread.current.object_id.abs}_#{object_id.abs}"
        InstanceExecHelper.module_eval{ define_method(mname, &block) }
        begin
          ret = send(mname, *args)
        ensure
          InstanceExecHelper.module_eval{ undef_method(mname) } rescue nil
        end
        ret
      end
    end
    
    def caesars_parser_depth_name
      [self.class, *@caesars_parser_depth].join('_')
    end


  end
end