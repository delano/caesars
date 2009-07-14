library :caesars, 'lib'

tryouts "Classes", :api do
  
  drill "create a class dynamically", '900' do
    a = Class.new String
    Caesars::Test1 = a
    Caesars::Test1.new '900'
  end
  
  drill "create a class with const_set", '901' do
    a = Class.new String
    Caesars.const_set :Test2, a
    Caesars::Test2.new '901'
  end
  
  dream [:one, :one=, :two, :three, :three=, :four, :four=, :five, :five=]
  drill "class attributes are ordered" do
    class Test3
      attr_accessor :one
      attr_reader :two
      attr_accessor :three, :four, :five
    end
    Test3.instance_methods false
  end
  
  drill "Class objects can have instance variables", 902 do
    class Test4
      send :attr_accessor, :classv
    end
    Test4.instance_variable_set :@one, 902
    Test4.instance_variable_get :@one
  end
  
end