require_relative 'generator'

class GeneratorRuBy < Generator

  LETTERS = "йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬББЮ"
  DIGITS = "0123456789"
  IS_DIGIT = proc { |a| self.class::DIGITS.include? a}
  IS_LETTER = proc { |a| self.class::LETTERS.include? a}

  def zip(state_id)
    substitute_x(find_by_id(table_name("zip_codes"), state_id)[1])
  end

  def street_n_build_no
    "#{ get_by_type("streets")[1] }, #{ (1 + rand(100)).to_s }, "
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