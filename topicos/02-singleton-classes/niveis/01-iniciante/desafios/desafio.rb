hash = { id: 123, nome: 'Caramelo' }
other_hash = { id: 789, nome: 'Rex' }

def hash.to_secret_json
  self.map { |k, v| { k.to_s => v } }
end
