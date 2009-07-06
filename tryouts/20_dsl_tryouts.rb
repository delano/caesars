# Notes:
# * Only specify class types for methods that expect blocks (Hash, Array, Complex). Everything else is handled by method missing. 
# * Handle specified methods only 


library :caesars, 'lib'
group "DSL Parsing"

tryouts "Rudiments" do
  
  
  dream ['Flavour', :greygoose, true]
  drill "write a DSL" do
    class ::Flavour < Caesars  #:nodoc: all
    end
    extend Flavour::DSL
    flavour do     
      vodka :greygoose 
      spicy true
    end
    [@flavour.class.to_s, @flavour.vodka, @flavour.spicy] 
  end
  
  
  drill "some type action" do
    class ::Flavour < Caesars 
      recipe Hash
      name 
    end
    Caesars.tree             # => { :recipe => hash_parser, :name => fun_parser }
    
  end
  
end

