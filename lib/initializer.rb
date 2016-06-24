require 'sqlite3'

class Initializer
  public 

  def initialize
    @db = SQLite3::Database.open "#{ DATABASE_FILE_PATH }"
    Dir.foreach(FILES_PATH) { |file|
      next if file == '.' || file == '..' || file.nil?
      tables = @db.execute("SELECT * FROM sqlite_master" \
      " WHERE name = '#{ file }' and type = 'table'")
      file_to_db(file) if (tables.size == 0)
    }
  end

  def db
    @db
  end

  private

  PROJECT_ROOT_PATH = "/home/egorrode/development/user_gen/"
  DATABASE_FILE_PATH = PROJECT_ROOT_PATH + "databases/user_generator.db"
  FILES_PATH = PROJECT_ROOT_PATH + "data/"

  def create_new_table(table_name)
    @db.execute "DROP TABLE IF EXISTS #{ table_name }"
    @db.execute "CREATE TABLE IF NOT EXISTS " +
    "#{ table_name }(Id INTEGER PRIMARY KEY, Label TEXT)"
  end

  def file_to_db(filename)
    if filename.include? "cities"
      cities_file_to_db(filename)
    else
      create_new_table(filename)
      file = File.new(FILES_PATH + filename, "r")
      insert_file_lines(filename, file, "Label")
    end
  end

  def insert_file_lines(table_name, file, field_name)
    i = 0
    @db.transaction
    while line == file.gets
      insert(table_name, field_name, i, line.gsub("\n",""))
      i += 1
    end
    @db.commit
    write_insert_stats(i, table_name)
  end

  def insert(table_name, field_name, id, value)
    @db.execute "INSERT INTO #{ table_name }" +
    "(Id,#{ field_name })VALUES (#{ id },\"#{ value }\")"
  end

  def cities_file_to_db(filename)
    create_new_cities_table(filename)
    file = File.new(FILES_PATH + filename, "r")
    insert_cities_file_lines(filename, file)
  end

  def create_new_cities_table(table_name)
    @db.execute "DROP TABLE IF EXISTS #{ table_name }"
    @db.execute "CREATE TABLE IF NOT EXISTS " +
    "#{ table_name }(Zone TEXT, Label TEXT)"
  end

  def insert_cities_file_lines(table_name, file)
    @db.transaction
    while line = file.gets
      line = line.split(";")
      zone = line[0]
      label = line[1].gsub("\n","")
      insert_city(table_name, zone, label)
       + 1
    end
    @db.commit
    # write_insert_stats(i, table_name)
  end

  def insert_city(table_name, zone, value)
    @db.execute "INSERT INTO #{ table_name }" +
    "(Zone,Label)VALUES (\"#{ zone }\",\"#{ value }\")"
  end

  def write_insert_stats(count, table_name)
    puts "added #{ count } lines to #{ table_name } table\n"
  end
end