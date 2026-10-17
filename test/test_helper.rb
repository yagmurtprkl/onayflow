ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors, with: :threads)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module AuthenticationTestHelper
  TEST_PASSWORD = "TestPassword123!"

  def log_in_as(user, password: TEST_PASSWORD)
    post login_path, params: { email: user.email, password: password }
    assert_response :redirect
  end
end

class ActionDispatch::IntegrationTest
  include AuthenticationTestHelper
end
