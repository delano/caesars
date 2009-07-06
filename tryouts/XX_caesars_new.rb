
library :caesars, 'lib'

tryouts "New syntax" do
  
  setup do
    Caesars.enable_debug
    # Define a Caesars class for all drills to use. Each drill needs to extend
    # this class since each drill runs in its own DrillContext instance. 
    class ::Machines < Caesars
      region do
        environment do
          role do
          end
        end
        
      end
      
      environment do
        role do
        end
      end
      
      role do
      end
      
      ami Scalar
      users Array
      nuthin Ignore, :global
    end
  end
  
  drill "Create a simple DSL", :celery do
    extend ::Machines::DSL
    #machines do
    #  region :celery
    #end
    #@machines.celery
    #@master.ingredient
    Caesars.caesars_tree
  end
  
  
end


