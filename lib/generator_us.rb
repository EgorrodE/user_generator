require_relative 'generator'

class GeneratorUS < Generator
  LETTERS = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
  DIGITS = "0123456789"

  def initialize(db, error_chance)
    @db = db
    @country = "US"
    @error_chance = error_chance
    @country_full_name = "USA"
  end
end