
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
      
      ami Proc
      users Array
      nuthin Ignore, :global
    end
  end
  
  drill "Create a simple DSL", :celery do
    extend ::Machines::DSL
    machines do
      region :'us-east-1' do
        environment :stage do
          ami :abcd
        end
        hihi 900
      end
      ami do
        :poop
      end
      users :a, :b
      users [:c, :d]
    end
    #stash Caesars.caesars_flat
    #@machines.celery
    #@master.ingredient
    @machines
  end
  
  
end


