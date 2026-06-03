class Familia
  class << self
    def class_attribute(attribute)
      instance_variavel_attribute = "@#{attribute}".to_sym
      instance_variable_set(instance_variavel_attribute, nil)

      singleton_class.define_method(attribute.to_sym) do
        return instance_variable_get(instance_variavel_attribute) if instance_variables.include?(instance_variavel_attribute)

        superclass.send(attribute.to_sym)
      end

      singleton_class.define_method("#{attribute}=".to_sym) do |value|
        instance_variable_set(instance_variavel_attribute, value)
      end
    end
  end
end

class Avo < Familia
  class_attribute :nome
  class_attribute :apelido
end

class Pai < Avo
  class_attribute :nome_de_pai
end

class Neto < Pai
  class_attribute :nome
  class_attribute :apelido
end

class Bisneto < Neto
end

puts
puts 'Estado inicial'
puts 'Avô ----------->'
puts "Avô nome: #{Avo.nome || 'nil'} - ObjectId: #{Avo.nome.object_id}"
puts "Avô apelido: #{Avo.apelido || 'nil'} - ObjectId: #{Avo.apelido.object_id}"
puts
puts 'Pai ----------->'
puts "Pai nome: #{Pai.nome || 'nil'} - ObjectId: #{Pai.nome.object_id}"
puts "Pai apelido: #{Pai.apelido || 'nil'} - ObjectId: #{Pai.apelido.object_id}"
puts "Pai nome_de_pai: #{Pai.nome_de_pai || 'nil'} - ObjectId: #{Pai.nome_de_pai.object_id}"
puts
puts 'Neto ----------->'
puts "Neto nome: #{Neto.nome || 'nil'} - ObjectId: #{Neto.nome.object_id}"
puts "Neto apelido: #{Neto.apelido || 'nil'} - ObjectId: #{Neto.apelido.object_id}"
puts "Neto nome_de_pai: #{Neto.nome_de_pai || 'nil'} - ObjectId: #{Neto.nome_de_pai.object_id}"
puts
puts 'Bisneto ----------->'
puts "Bisneto nome: #{Bisneto.nome || 'nil'} - ObjectId: #{Bisneto.nome.object_id}"
puts "Bisneto apelido: #{Bisneto.apelido || 'nil'} - ObjectId: #{Bisneto.apelido.object_id}"
puts "Bisneto nome_de_pai: #{Bisneto.nome_de_pai || 'nil'} - ObjectId: #{Bisneto.nome_de_pai.object_id}"
puts

puts "Atribui 'Avo' no nome do Avo: o objeto nome do Avo é diferente nas classes filhas que sobrescreveram o atributo nome"
Avo.nome = 'Avo'

puts "Avô nome: #{Avo.nome || 'nil'} - ObjectId: #{Avo.nome.object_id}"
puts "Pai nome: #{Pai.nome || 'nil'} - ObjectId: #{Pai.nome.object_id}"
puts "Neto nome: #{Neto.nome || 'nil'} - ObjectId: #{Neto.nome.object_id}"
puts "Bisneto nome: #{Bisneto.nome || 'nil'} - ObjectId: #{Bisneto.nome.object_id}"
puts

puts "Atribui 'Neto' no nome do Neto: o objeto nome do Neto é o mesmo que o objeto nome de Bisneto, pois não sobrescreveu nome"
Neto.nome = 'Neto'

puts "Avô nome: #{Avo.nome || 'nil'} - ObjectId: #{Avo.nome.object_id}"
puts "Pai nome: #{Pai.nome || 'nil'} - ObjectId: #{Pai.nome.object_id}"
puts "Neto nome: #{Neto.nome || 'nil'} - ObjectId: #{Neto.nome.object_id}"
puts "Bisneto nome: #{Bisneto.nome || 'nil'} - ObjectId: #{Bisneto.nome.object_id}"
puts

puts "Atribui 'Bisneto' no nome do Bisneto: o objeto nome de Bisneto se torna diferente do objeto nome de Neto"
Bisneto.nome = 'Bisneto'

puts "Avô nome: #{Avo.nome || 'nil'} - ObjectId: #{Avo.nome.object_id}"
puts "Pai nome: #{Pai.nome || 'nil'} - ObjectId: #{Pai.nome.object_id}"
puts "Neto nome: #{Neto.nome || 'nil'} - ObjectId: #{Neto.nome.object_id}"
puts "Bisneto nome: #{Bisneto.nome || 'nil'} - ObjectId: #{Bisneto.nome.object_id}"
puts
