require_relative "../../lib/generator_us"
require_relative "../../lib/initializer"
require "test/unit"

class TestGeneratorUS < Test::Unit::TestCase
  USER_REGEXP = /.+ .+; \d+ .+(\.)*, (.+ \d+,)*.+, .+, .+, \d+, .+; \+\d+\(\d+\)\d+-\d+-\d+/
  GENERATOR = GeneratorUS

  def test_with_error
    @db ||= Initializer.new.db
    @generator ||= GENERATOR.new(@db, 1)
    @user_with_error = @generator.user
    assert_match(USER_REGEXP, @user_with_error) 
    assert(has_error?)
  end

  def test_without_error
    @db ||= Initializer.new.db
    @generator ||= GENERATOR.new(@db, 1)
    assert_match(USER_REGEXP, @generator.user)
  end

  def has_error?
    @user_with_error != @generator.current_user
  end
end