require 'slop'

class Main

  def initialize
    init_args(ARGV)
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
    else
      puts @opts
    end
  end

  def start
    generate_n_print_users if @generator
  end

  private

  def init_args(args)
    @opts = Slop.parse args do |o|
      o.string '-c', '--country', suppress_error: true
      o.integer '-n', '--number', default: 1
      o.float '-e', '--error', default: 0
    end
    @country = @opts[:country]
    @count = @opts[:number]
    @error_chance = @opts[:error]
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
end
