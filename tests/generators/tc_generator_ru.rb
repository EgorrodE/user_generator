require_relative "../../lib/generator_ru"
require_relative "../../lib/database"
require "test/unit"

class TestGeneratorRu < Test::Unit::TestCase
  USER_REGEXP = /.+ .+; .+\., \d+,( .+ \d+,)* .*\. .+,(( .+\. .+)|( .+ .+( .+)*)), \d+, .+; \+\d+\(\d+\)\d+-\d+-\d+/
  GENERATOR = GeneratorRu

  def test_with_error
    @db ||= Database.new.db
    @generator = GENERATOR.new(@db, 1)
    100.times do
      @new_user = @generator.new_user
      assert_match(USER_REGEXP, @new_user) 
      assert(error?, "#{@generator.last_error_code}\n" +
        "#{@new_user}\n#{@generator.current_user}")
    end
  end

  def test_without_error
    @db ||= Database.new.db
    @generator = GENERATOR.new(@db, 0)
    100.times do
      @new_user = @generator.new_user
      assert_match(USER_REGEXP, @new_user)
      assert(!error?, "#{@generator.last_error_code}\n" +
        "#{@new_user}\n#{@generator.current_user}")
    end
  end

  def error?
    @new_user != @generator.current_user
  end
end
