require 'slop'

class Main
  VALID_COUTRIES = "BY RU US"

  def initialize
    init_args(ARGV)
    db = Database.new.db
    gen_class = nil
    case @country
    when "US"
      gen_class = GeneratorUS
    when "RU"
      gen_class = GeneratorRu
    when "BY"
      gen_class = GeneratorBy
    end
    @generator = gen_class.new(db, @error_chance) unless gen_class.nil?
  end

  def start
    generate_n_print_users if @generator
  end

  private

  def init_args(args)
    opts = Slop.parse args do |o|
      o.string '-c', '--country', default: ""
      o.integer '-n', '--number', default: 1
      o.float '-e', '--error', default: 0
    end
    @country = opts[:country]
    @count = opts[:number]
    @error_chance = opts[:error]
    if(@country == "")
      puts opts
    elsif !VALID_COUTRIES.include? @country
      puts "invalid arguments"
    end
  end

  def generate_n_print_users
    @count.times do
      puts @generator.new_user
    end
  end
end
