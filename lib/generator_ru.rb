require_relative 'generator'

class GeneratorRu < Generator
  LETTERS = "йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬББЮ"
  DIGITS = "0123456789"

  def initialize(db, error_chance)
    super(db, error_chance)
    @country = "RU"
    @country_full_name = "Россия"
  end

  protected
  
  def zip(state_id)
    substitute_x(find_by_id(table_name("zip_codes"), state_id)[:label])
  end

  def street_n_build_no
    "#{ get_by_type("streets")[:label] }, #{ (1 + rand(100)).to_s }, "
  end
end