class Animal; end
class Dog < Animal; end

thor = Dog.new
puts Dog.ancestors.inspect
# => [Dog, Animal, Object, Kernel, BasicObject]
