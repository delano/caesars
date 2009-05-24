LIBRARY_PATH = File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "caesars"))

#group "baseline"

library :caesars, LIBRARY_PATH

dreams File.join(GYMNASIUM_HOME, "baseline_dreams.rb")
tryout "Common Usage", :api do
  setup do
    @@master = :fluff
  end
  
  drill "Create a simple DSL" do
    class Simple < Caesars; end
    extend Simple::DSL
    simple do
      works :true
    end
    @simple.works
  end
  
  drill "Store Block" do
    class Multiplier < Caesars; chill :calc; end
    extend Multiplier::DSL
    multiplier do
      calc do; end
    end
    @multiplier.calc
  end
  
  dream "Create a complex DSL", true
  drill "Create a complex DSL" do
    p [:dsl, self]
    p [:master, @@master]
    true
  end
  
  
end