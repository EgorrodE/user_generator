require_relative "../../lib/generator_by"
require_relative "../../lib/initializer"
require "test/unit"

class TestGeneratorBy < Test::Unit::TestCase
  USER_REGEXP = /.+ .+; .+\., \d+,( .+ \d+,)* г*\. .+,(( .+\. .+)|( .+ .+( .+)*)), \d+, .+; \+\d+\(\d+\)\d+-\d+-\d+/
  GENERATOR = GeneratorBy

  def test_with_error
    @db ||= Initializer.new.db
    @generator = GENERATOR.new(@db, 1)
    @new_user = @generator.new_user
    assert_match(USER_REGEXP, @new_user) 
    assert(error?)
  end

  def test_without_error
    @db ||= Initializer.new.db
    @generator = GENERATOR.new(@db, 0)
    @new_user = @generator.new_user
    assert_match(USER_REGEXP, @new_user)
    assert(!error?)
  end

  def error?
    @new_user != @generator.current_user
  end
end