
group "baseline"

library :caesars, 'lib'

tryout "Common Usage", :api do
  setup do
    #Caesars.enable_debug
    # Define a Caesars class for all drills to use. Each drill needs to extend
    # this class since each drill runs in its own DrillContext instance. 
    class Master < Caesars
      chill :calc
      forced_array :fluff
      forced_hash :fhashion
    end
  end
  
  drill "Create a simple DSL", :true do
    extend Master::DSL
    master do
      works :true
    end
    @master.works
  end
  
  dream :class, Proc 
  drill "Store Block" do
    extend Master::DSL
    master do
      calc do; end
    end
    @master.calc
  end
  
  dream :class, Proc
  drill "Forced Array blocks are always chilled" do
    extend Master::DSL
    master do 
      fluff :ignore
      fluff :inline do; end
    end
    # We created two fluff elements above. We want the last one which
    # itself has two elements: [:inline, Proc]. We want the Proc. 
    @master.fluff.last.last
  end
  
  dream ['box', 'pot']
  drill "can force hash" do
    
    extend Master::DSL
    master do
      fhashion 'box' do
      end
      fhashion 'pot' do
      end
    end
    @master.fhashion.keys.sort  # => box, pot
  end
  
  dream [9, 9]
  drill "forced hash methods take multiple arguments" do
    
    extend Master::DSL
    master do
      fhashion 'box', 'pot' do
        oranges 9
      end
    end
    [@master.fhashion.box.oranges, @master.fhashion.pot.oranges]
  end
end
