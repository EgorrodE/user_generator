require_relative 'generator'

class GeneratorUS < Generator
  LETTERS = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
  DIGITS = "0123456789"

  def initialize(db, error_chance)
    super(db, error_chance)
    @country = "US"
    @country_full_name = "USA"
  end
end