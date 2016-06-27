require_relative 'generator'

class GeneratorRu < Generator
  LETTERS = "йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬББЮ"
  DIGITS = "0123456789"

  protected
  
  def zip(state_id)
    substitute_x(find_by_id(table_name("zip_codes"), state_id)[:label])
  end

  def street_n_build_no
    "#{ get_by_type("streets")[:label] }, #{ (1 + rand(100)).to_s }, "
  end

  def table_name(table_type)
    table = table_type + "_"
    case table_type
    when "cities", "phones", "states", "zip_codes"
      table += @country
    when "firstnames", "lastnames", "secondary_prefix", "streets"
      table += "RU_BY"
    end
  end
end