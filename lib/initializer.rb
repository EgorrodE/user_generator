require 'sequel'

class Initializer
  public 

  def initialize
    @db = Sequel.sqlite "#{ DATABASE_FILE_PATH }"
    Dir.foreach(DATA_FILES_PATH) { |file|
      next if file == '.' || file == '..' || file.nil?
      file_to_db(file) unless @db.table_exists?(:"#{ file }")
    }
  end

  def db
    @db
  end

  private

  PROJECT_ROOT_PATH = ""
  DATABASE_FILE_PATH = PROJECT_ROOT_PATH + "databases/user_generator.db"
  DATA_FILES_PATH = PROJECT_ROOT_PATH + "data/"

  def file_to_db(filename)
    if filename.include? "cities"
      cities_file_to_db(filename)
    else
      create_new_table(filename)
      file = File.new(DATA_FILES_PATH + filename, "r")
      insert_file_lines(filename, file)
    end
  end

  def create_new_table(table_name)
    @db.create_table?(:"#{ table_name }") do
      primary_key :id
      string :label
    end
  end

  def insert_file_lines(table_name, file)
    i = 0
    @db.transaction do
      while line = file.gets
        insert(table_name, i, line.gsub("\n",""))
        i += 1
      end
    end
  end

  def insert(table_name, id, value)
    @db[:"#{table_name}"].insert(:id => id, :label => value)
  end

  def cities_file_to_db(filename)
    create_new_cities_table(filename)
    file = File.new(DATA_FILES_PATH + filename, "r")
    insert_cities_file_lines(filename, file)
  end

  def create_new_cities_table(table_name)
    @db.create_table?(:"#{ table_name }") do
      string :zone
      string :label
    end
  end

  def insert_cities_file_lines(table_name, file)
    @db.transaction do
      while line = file.gets
        line = line.split(";")
        zone = line[0]
        label = line[1].gsub("\n","")
        insert_city(table_name, zone, label)
      end
    end
  end

  def insert_city(table_name, zone, value)
    @db[:"#{ table_name }"].insert(:zone => zone, :label => value)
  end
end