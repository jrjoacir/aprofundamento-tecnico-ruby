# Nível: Iniciante
# Uso básico de herança e visualização da cadeia de herança com o método .ancestors.

class Animal; end
class Dog < Animal; end

thor = Dog.new
puts Dog.ancestors.inspect
# => [Dog, Animal, Object, Kernel, BasicObject]
