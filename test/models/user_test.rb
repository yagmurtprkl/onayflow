require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes email before saving" do
    user = User.create!(
      name: "Yeni Çalışan",
      email: "  NEW.USER@EXAMPLE.TEST ",
      password: "SecurePassword123!",
      role: :employee
    )

    assert_equal "new.user@example.test", user.email
  end

  test "requires unique email" do
    duplicate = User.new(
      name: "Kopya",
      email: users(:employee).email.upcase,
      password: "SecurePassword123!",
      role: :employee
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "authenticates with password digest" do
    assert users(:employee).authenticate(AuthenticationTestHelper::TEST_PASSWORD)
    assert_not users(:employee).authenticate("wrong-password")
  end
end
