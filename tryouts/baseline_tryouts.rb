LIBRARY_PATH = File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "caesars"))

group "baseline"

library :caesars, LIBRARY_PATH

dreams File.join(GYMNASIUM_HOME, "baseline_dreams.rb")
tryout "Common Usage", :api do
  setup do
    # Define a Caesars class for all drills to use. Each drill needs to extend
    # this class since each drill runs in its own DrillContext instance. 
    class Master < Caesars
      chill :calc
      forced_array :fluff
    end
  end
  
  drill "Create a simple DSL" do
    extend Master::DSL
    master do
      works :true
    end
    @master.works
  end
  
  drill "Store Block" do
    extend Master::DSL
    master do
      calc do; end
    end
    @master.calc
  end
  
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
end