require 'sequel'
require_relative "data_importer"

class Database
  PROJECT_ROOT_PATH = File.join(File.dirname(__FILE__),"../")
  DATABASE_FILE_PATH = PROJECT_ROOT_PATH + "databases/user_generator.db"

  attr_reader :db

  def initialize
    if File.exist?(DATABASE_FILE_PATH)
      @db = Sequel.sqlite "#{ DATABASE_FILE_PATH }"
    else
      @db = DataImporter.new.db
    end
  end
end