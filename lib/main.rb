

class Main

  def initialize
    if args_valid_n_initialized?
      db = Initializer.new.db
      case @country
      when "US"
        @generator = Generator.new(db, @country, @error_chance, "USA")
      when "RU"
        @generator = GeneratorRuBy.new(
          db, @country, @error_chance,"Россия")
      when "BY"
        @generator = GeneratorRuBy.new(
          db, @country, @error_chance, "Беларусь")
      end
      generate_n_print_users
    end
  end

  private

  def valid_countries 
    "BY_RU_US"
  end

  def max_count 
    1_000_000
  end

  def generate_n_print_users
    i = 0
    while i < @count
      user = @generator.user
      if user
        puts user
        i += 1
      end
    end
  end

  def args_valid_n_initialized?
    if valid_ARGV?
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
    @country = ARGV[0]
    @count = ARGV[1].to_i
    @error_chance = ARGV[2].to_f
  end

  def valid_args?
    valid_country? && valid_count? && valid_error_chance?
  end

  def valid_country?
    valid_countries.include? @country
  end

  def valid_count?
    @count > 0 && @count <= max_count
  end

  def valid_error_chance?
    @error_chance >= 0 && @error_chance <= 1
  end
end
