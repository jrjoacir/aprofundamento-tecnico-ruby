module MyModule
  def my_method
    'This is my method'
  end
end

class MyIncludeClass
  class << self
    include MyModule
  end
end

class MyExtendClass
  extend MyModule
end

MyIncludeClass.singleton_class #=> #<Class:MyIncludeClass>
MyIncludeClass.singleton_methods #=> [:my_method]
MyIncludeClass.new.my_method #<main>': undefined method `my_method' for #<MyIncludeClass:0x00007e314bd10628> (NoMethodError)
MyIncludeClass.my_method #=> "This is my method"


MyExtendClass.singleton_class #=> #<Class:MyExtendClass>
MyExtendClass.singleton_methods #=> [:my_method]
MyExtendClass.new.my_method #<main>': undefined method `my_method' for #<MyExtendClass:0x00007e314bd5a278> (NoMethodError)
MyExtendClass.my_method #=> "This is my method"



# Parece não ter diferença. Checar.