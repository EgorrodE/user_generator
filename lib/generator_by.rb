require_relative 'generator_ru'

class GeneratorBy < GeneratorRu
  LETTERS = "йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬББЮ"
  DIGITS = "0123456789"

  def initialize(db, error_chance)
    @db = db
    @country = "BY"
    @error_chance = error_chance
    @country_full_name = "Беларусь"
  end
end