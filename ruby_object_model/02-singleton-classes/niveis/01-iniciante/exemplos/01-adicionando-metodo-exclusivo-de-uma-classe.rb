# Nível: Iniciante
# Adicionando um método exclusivo a uma única instância de uma classe (String).

str1 = "Olá"
str2 = "Mundo"

# Define um método apenas para str1
def str1.gritar
  self.upcase + "!!!"
end

puts str1.gritar # => "OLÁ!!!"
# puts str2.gritar # => NoMethodError
