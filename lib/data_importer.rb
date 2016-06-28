require 'sequel'

class DataImporter
  PROJECT_ROOT_PATH = File.join(File.dirname(__FILE__),"../")
  DATABASE_FILE_PATH = PROJECT_ROOT_PATH + "databases/user_generator.db"
  DATA_FILES_PATH = PROJECT_ROOT_PATH + "data/"

  attr_reader :db

  def initialize
    puts "Initializing gatabase..."
    @db = Sequel.sqlite "#{ DATABASE_FILE_PATH }"
    datafiles = File.join(DATA_FILES_PATH,"**","*")
    Dir.glob(datafiles).each { |file|
      next if file == '.' || file == '..' || file.nil? || File.directory?(file)
      filename = File.basename(file)
      file_to_db(file, filename) unless @db.table_exists?(:"#{ filename }")
    }
  end

  private

  def file_to_db(file, filename)
    if filename.include? "cities"
      cities_file_to_db(file, filename)
    else
      create_new_table(filename)
      insert_file_lines(filename, file)
    end
  end

  def create_new_table(table_name)
    @db.create_table?(:"#{ table_name }") do
      primary_key :id
      string :label
    end
  end

  def insert_file_lines(table_name, file_path)
    i = 0
    file = File.new(file_path)
    @db.transaction do
      while line = file.gets
        insert(table_name, i, line.gsub("\n",""))
        i += 1
      end
    end
    # puts "#{i} to #{table_name}"
  end

  def insert(table_name, id, value)
    @db[:"#{table_name}"].insert(:id => id, :label => value)
  end

  def cities_file_to_db(file, filename)
    create_new_cities_table(filename)
    insert_cities_file_lines(filename, file)
  end

  def create_new_cities_table(table_name)
    @db.create_table?(:"#{ table_name }") do
      string :zone
      string :label
    end
  end

  def insert_cities_file_lines(table_name, file_path)
    file = File.new(file_path)
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