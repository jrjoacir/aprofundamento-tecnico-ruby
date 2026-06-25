# Nível: Avançado
# Manipulação dinâmica da cadeia em tempo de execução e interceptação com method_missing combinado com respond_to_missing?.

class DynamicFinder
  def initialize(data)
    @data = data
  end

  # Se o método começar com "find_by_", interceptamos
  def method_missing(method_name, *args, &block)
    if method_name.to_s.start_with?("find_by_")
      attribute = method_name.to_s.sub("find_by_", "")
      return @data.select { |item| item[attribute.to_sym] == args.first }
    end
    super
  end

  # Essencial para um Sênior: sempre que sobrescrever method_missing, mude respond_to_missing?
  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?("find_by_") || super
  end
end

finder = DynamicFinder.new([{ name: "Alice", role: "Dev" }, { name: "Bob", role: "PM" }])
puts finder.find_by_role("Dev").inspect # => [{:name=>"Alice", :role=>"Dev"}]
puts finder.respond_to?(:find_by_role)   # => true
