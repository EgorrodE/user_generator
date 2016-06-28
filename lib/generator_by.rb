require_relative 'generator_ru'

class GeneratorBy < GeneratorRu
  LETTERS = "йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬББЮ"
  DIGITS = "0123456789"

  def initialize(db, error_chance)
    super(db, error_chance)
    @country = "BY"
    @country_full_name = "Беларусь"
  end
end