require 'sqlite3'

class Generator

  def initialize(db, country, error_chance, country_full_name)
    @db = db
    @country = country
    @error_chance = error_chance
    @country_full_name = country_full_name
  end

  LETTERS = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
  DIGITS = "0123456789"

  def user
    user = name
    user += address
    add_error(user) if rand <= @error_chance && user != ""
    user
  end

  def is_digit
    proc { |a| self.class::DIGITS.include? a}
  end

  def is_letter
    proc { |a| self.class::LETTERS.include? a}
  end

  def name
    types = ["firstnames","lastnames"]
    get_by_types_array(types, " ", "; ")
  end

  def address
    address = street_n_build_no
    address += secondary_address if has_secondary_address?
    address += state_city_zip_phone
  end

  def add_error(line)
    k = rand(6)
    case k
    when 0 # swap near digits
      chars = get_chars_array(line, is_digit)
      swap_near(line,chars)
    when 1 # replase digit with another
      char = get_chars_array(line, is_digit).sample
      line[char[0]] = rand(10).to_s
    when 2 # remove letter
      char = get_chars_array(line, is_letter).sample
      line[char[0]] = ""
    when 3 # double letter
      char = get_chars_array(line, is_letter).sample
      line[char[0]] = "#{ char[1] * 2 }"
    when 4 # swap near letters
      chars = get_chars_array(line, is_letter)
      swap_near(line,chars)
    when 5 # insert letter
      char = get_chars_array(line, is_letter).sample
      line[char[0]] = char[1] + self.class::LETTERS.chars.sample
    end
    line
  end

  def swap_near(line,chars)
    loop do
      i = rand(chars.size)
      if i != chars.size - 1 && chars[i][0] == chars[i + 1][0] - 1
        line[chars[i][0]],line[chars[i + 1][0]] =
          line[chars[i + 1][0]],line[chars[i][0]]
        break
      end
    end
    line
  end

  def get_chars_array(line, is)
    line.chars.map.with_index{ |x,i| [i,x] if is.call(x) }.compact
  end

  def state_city_zip_phone
    state = rand_from_table(table_name("states"))
    state_id = state[0]
    state_name = state[1]
    "#{ city_name(state_name) }, #{ state_name }, " +
      "#{ zip(state_id) }, #{ get_full_country }; " +
      "#{ phone(state_id) }"
  end

  def zip(state_id)
    find_by_id(
      table_name("zip_codes"),
      state_id)[1] + ", " + (1 + rand(99999)
    ).to_s
  end

  def phone(state_id)
    substitute_x(find_by_id(table_name("phones"),state_id)[1])
  end

  def city_name(state_name)
    rand_from_table_by_zone(table_name("cities"), state_name)[1]
  end

  def get_full_country
    @country_full_name
  end

  def street_n_build_no
    types = ["streets","street_sufixes"]
    "#{ (1 + rand(1000)).to_s } #{ get_by_types_array(types, " ", "") }, "
  end

  def secondary_address
    "#{ get_by_type("secondary_prefix")[1] } #{ (1 + rand(100)).to_s }, "
  end

  def has_secondary_address?
    rand(2) == 1
  end

  def get_by_types_array(table_types, middle_separator, last_separator)
    result = ""
    table_types.each_index{ |i|
      tmp = get_by_type(table_types[i])[1]
      if tmp != ""
        result += tmp
        result += middle_separator if i != table_types.size - 1
      end
    }
    result += last_separator
  end

  def get_by_type(table_type)
    rand_from_table(table_name(table_type))
  end

  def table_name(table_type)
    "#{ table_type }_#{ @country }"
  end

  def substitute_x(str)
    str.gsub("x"){ rand(10).to_s }
  end

  def rand_from_table_by_zone(table_name, zone)
    @db.execute("SELECT * FROM #{ table_name } " +
              "WHERE Zone = \"#{ zone }\"").sample
  end

  def rand_from_table(table_name)
    id = rand(table_size(table_name))
    find_by_id(table_name, id)
  end

  def find_by_id(table_name, id)
    @db.execute("SELECT * FROM #{ table_name } WHERE Id = #{ id }")[0]
  end

  def table_size(table_name)
    @db.execute("SELECT COUNT(*) FROM #{ table_name }")[0][0]
  end
end