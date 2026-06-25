# Nível: Avançado
# Acessando a Singleton Class explicitamente e definindo métodos dinamicamente nela através de escopos léxicos fechados.

class Product
  def self.create_class_finder(field)
    # Acessamos a singleton_class da classe Product
    singleton_class.class_eval do
      define_method("find_by_#{field}") do |value|
        "Buscando Product por #{field} com o valor: #{value}"
      end
    end
  end
end

Product.create_class_finder(:sku)
puts Product.find_by_sku("PROD-999") # => "Buscando Product por sku com o valor: PROD-999"
