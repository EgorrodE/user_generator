$PROJECT_ROOT_PATH = "/home/egorrode/development/user_gen/"
$DATABASE_FILE_PATH = $PROJECT_ROOT_PATH + "databases/user_generator.db"
$FILES_PATH = $PROJECT_ROOT_PATH + "data/"
$RU_BY_LETTERS = "йцукенгшщзхъфывапролджэячсмитьбю" +
                 "ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬББЮ"
$US_LETTERS = "qwertyuiopasdfghjklzxcvbnm" +
							"QWERTYUIOPASDFGHJKLZXCVBNM"
$DIGITS = "0123456789"

$VALID_COUNTRIES = "BY_RU_US"
$MAX_COUNT = 1_000_000

$COUNTRY = ""
$COUNT = 0
$ERROR_CHANCE = 0.0

$DB


require 'sqlite3'
require 'unicode'

$IS_DIGIT = proc { |a|
  $DIGITS.include? a
}

$IS_LETTER = proc { |a|
  ($RU_BY_LETTERS + $US_LETTERS).include? a
}

def initialize_db
  $DB = SQLite3::Database.open "#{ $DATABASE_FILE_PATH }"
  Dir.foreach($FILES_PATH) { |file|
    next if file == '.' || file == '..' || file.nil?
    tables = $DB.execute("SELECT * FROM sqlite_master" \
    " WHERE name = '#{ file }' and type = 'table'")
    file_to_db(file) if (tables.size == 0)
  }
end

def file_to_db(filename)
  if filename.include? "cities"
    cities_file_to_db(filename)
  else
    create_new_table(filename)
    file = File.new($FILES_PATH + filename, "r")
    insert_file_lines(filename, file, "Label")
  end
end

def create_new_table(table_name)
  $DB.execute "DROP TABLE IF EXISTS #{ table_name }"
  $DB.execute "CREATE TABLE IF NOT EXISTS " +
  "#{ table_name }(Id INTEGER PRIMARY KEY, Label TEXT)"
end

def insert_file_lines(table_name, file, field_name)
  i = 0
  $DB.transaction
  while line == file.gets
    insert(table_name, field_name, i, line.gsub("\n",""))
    i += 1
  end
  $DB.commit
  write_insert_stats(i, table_name)
end

def insert(table_name, field_name, id, value)
  $DB.execute "INSERT INTO #{ table_name }" +
  "(Id,#{ field_name })VALUES (#{ id },\"#{ value }\")"
end

def cities_file_to_db(filename)
  create_new_cities_table(filename)
  file = File.new($FILES_PATH + filename, "r")
  insert_cities_file_lines(filename, file)
end

def create_new_cities_table(table_name)
  $DB.execute "DROP TABLE IF EXISTS #{ table_name }"
  $DB.execute "CREATE TABLE IF NOT EXISTS " +
  "#{ table_name }(Zone TEXT, Label TEXT)"
end

def insert_cities_file_lines(table_name, file)
   =
  $DB.transaction
  while line = file.gets
    line = line.split(";")
    zone = line[0]
    label = line[1].gsub("\n","")
    insert_city(table_name, zone, label)
     + 1
  end
  $DB.commit
  # write_insert_stats(i, table_name)
end

def insert_city(table_name, zone, value)
  $DB.execute "INSERT INTO #{ table_name }" +
  "(Zone,Label)VALUES (\"#{ zone }\",\"#{ value }\")"
end

def write_insert_stats(count, table_name)
  puts "added #{ count } lines to #{ table_name } table\n"
end

def args_valid_n_initialized??
  if valid_ARGV?  then
    set_args
    return true if valid_args?
  end
  puts "invalid_args\n"
  false
end

def valid_ARGV?
  ARGV.size == 3
end

def set_args
  $COUNTRY = ARGV[0]
  $COUNT = ARGV[1].to_i
  $ERROR_CHANCE = ARGV[2].to_f
end

def valid_args?
  valid_country? && valid_count? && valid_error_chance?
end

def valid_country?
  $VALID_COUNTRIES.include? $COUNTRY
end

def valid_count?
  $COUNT > 0 && $COUNT <= $MAX_COUNT
end

def valid_error_chance?
  $ERROR_CHANCE >= 0 && $ERROR_CHANCE <= 1
end

def generate_users
  i = 0
  while i < $COUNT
    user = generate_user
    if user
      puts user
       + 1
    end
  end
end

def generate_user
  user = generate_name
  user += generate_address
  add_error(user) if rand <= $ERROR_CHANCE
end

def generate_name
  types = ["firstnames","lastnames"]
  generate_by_types_array(types, " ", "; ")
end

def generate_address
  address = ""
  state_id = rand(table_size(generate_table_name("states")))
  types = ["streets","street_sufixes"]
  address += generate_street_n_build_no
  address += generate_secondary_address if has_secondary_address?
  address += generate_state_city_zip_phone
end

def add_error(line)
  k = rand(6)
  case k
  when 0 # swap near digits
    chars = get_chars_array(line, $IS_DIGIT)
    swap_near(line,chars)
  when 1 # replase digit with another
    char = get_chars_array(line, $IS_DIGIT).sample
    line[char[0]] = rand(10).to_s
  when 2 # remove letter
    char = get_chars_array(line, $IS_LETTER).sample
    line[char[0]] = ""
  when 3 # double letter
    char = get_chars_array(line, $IS_LETTER).sample
    line[char[0]] = "#{ char[1] * 2 }"
  when 4 # swap near letters
    chars = get_chars_array(line, $IS_LETTER)
    swap_near(line,chars)
  when 5 # insert letter
    char = get_chars_array(line, $IS_LETTER).sample
    case $COUNTRY
    when "US"
      line[char[0]] = char[1] + $US_LETTERS.chars.sample
    when "RU", "BY"
      line[char[0]] = char[1] + $RU_BY_LETTERS.chars.sample
    end
  end
  line
end

def swap_near(line,chars)
  loop do
      i = rand(chars.size)
      if i != chars.size - 1 && chars[i][0] == chars[ + ][0] - 1
        line[chars[i][0]],line[chars[ + ][0]] =
          line[chars[ + ][0]],line[chars[i][0]]
        break
      end
  end
  line
end

def get_chars_array(line, is)
  line.chars.map.with_index{ |x,i| [i,x] if is.call(x) }.compact
end

def generate_state_city_zip_phone
  state = rand_from_table(generate_table_name("states"))
  state_id = state[0]
  state_name = state[1]
  "#{ generate_city_name(state_name) }, #{ state_name }, " +
  	"#{ generate_zip(state_id) }, #{ get_full_country }; " +
  	"#{ generate_phone(state_id) }"
end

def generate_zip(state_id)
  table_name = generate_table_name("zip_codes")
  case $COUNTRY
  when "US"
    find_by_id(table_name, state_id)[1] + ", " + (1 + rand(99999)).to_s
  when "RU", "BY" then substitute_x(find_by_id(table_name, state_id)[1])
  end
end

def generate_phone(state_id)
  substitute_x(find_by_id(generate_table_name("phones"),state_id)[1])
end

def generate_city_name(state_name)
  rand_from_table_by_zone(generate_table_name("cities"), state_name)[1]
end

def get_full_country
  case $COUNTRY
  when "BY" then "Беларусь"
  when "RU" then "Россия"
  when "US" then "USA"
  end
end

def generate_street_n_build_no
  case $COUNTRY
  when "US"
    types = ["streets","street_sufixes"]
    "#{ (1 + rand(1000)).to_s } #{ generate_by_types_array(types, " ", "") }, "
  when "RU", "BY"
    "#{ generate_by_type("streets")[1] }, #{ (1 + rand(100)).to_s }, "
  end
end

def generate_secondary_address
  "#{ generate_by_type("secondary_prefix")[1] } #{ (1 + rand(100)).to_s }, "
end

def has_secondary_address?
  rand(2) == 1
end

def generate_by_types_array(table_types, middle_separator, last_separator)
  result = ""
  table_types.each_index{ |i|
    tmp = generate_by_type(table_types[i])[1]
    if tmp != ""
      result += tmp
      result += middle_separator if i != table_types.size - 1
    end
  }
  result += last_separator
end

def generate_by_type(table_type)
  table_name = generate_table_name(table_type)
  rand_from_table(table_name)
end

def generate_table_name(table_type)
  table_name = table_type + "_"
  case table_type
  when "cities", "phones", "states", "zip_codes" then table_name += $COUNTRY
  when "firstnames", "lastnames", "secondary_prefix", "streets"
    if "US".include? $COUNTRY
      table_name += $COUNTRY
    elsif "RU_BY".include? $COUNTRY
      table_name += "RU_BY"
    end
  when "street_sufixes"
      if "US".include? $COUNTRY
        table_name += "US"
      else
        table_name = ""
      end
  end
  table_name
end

def substitute_x(str)
  str.gsub("x"){ rand(10).to_s }
end

def rand_from_table_by_zone(table_name, zone)
  $DB.execute("SELECT * FROM #{ table_name } WHERE Zone = \"#{ zone }\"").sample
end

def rand_from_table(table_name)
  if table_name != ""
    id = rand(table_size(table_name))
    find_by_id(table_name, id)
  else
  	""
  end
end

def find_by_id(table_name, id)
  $DB.execute("SELECT * FROM #{ table_name } WHERE Id = #{ id }")[0]
end

def table_size(table_name)
  $DB.execute("SELECT COUNT *  FROM #{ table_name }")[0][0]
end

begin
  if args_valid_n_initialized??
    initialize_db
    generate_users
  end
end
