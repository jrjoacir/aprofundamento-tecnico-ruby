module Electric
  def turn_on
    "Electric Vrumm"
  end
end

class Vehicle
  prepend Electric
end

class Car < Vehicle
  def turn_on
    "Car Vrumm"
  end
end

puts Car.new.turn_on
# => "Electric Vrumm"
