require "test_helper"

class ProductionDemoProvisionerTest < ActiveSupport::TestCase
  test "refuses to provision outside production" do
    error = assert_raises(ProductionDemoProvisioner::ConfigurationError) do
      ProductionDemoProvisioner.new(environment: ActiveSupport::StringInquirer.new("test"), variables: {}).call!
    end

    assert_equal "Demo provisioning is production-only.", error.message
  end

  test "requires explicit opt in and strong distinct credentials" do
    variables = valid_variables.merge("ONAYFLOW_ALLOW_PRODUCTION_DEMO" => "false")

    assert_raises(ProductionDemoProvisioner::ConfigurationError) do
      provisioner(variables).call!
    end

    variables = valid_variables.merge("ONAYFLOW_DEMO_MANAGER_PASSWORD" => "short")
    assert_raises(ProductionDemoProvisioner::ConfigurationError) do
      provisioner(variables).call!
    end

    shared_password = "DistinctPasswordRequired!"
    variables = valid_variables.merge(
      "ONAYFLOW_DEMO_EMPLOYEE_PASSWORD" => shared_password,
      "ONAYFLOW_DEMO_MANAGER_PASSWORD" => shared_password
    )
    assert_raises(ProductionDemoProvisioner::ConfigurationError) do
      provisioner(variables).call!
    end
  end

  test "provisions two idempotent accounts without fixed credentials" do
    variables = valid_variables

    assert_difference("User.count", 2) { provisioner(variables).call! }
    assert_no_difference("User.count") { provisioner(variables).call! }

    employee = User.find_by!(email: variables.fetch("ONAYFLOW_DEMO_EMPLOYEE_EMAIL"))
    manager = User.find_by!(email: variables.fetch("ONAYFLOW_DEMO_MANAGER_EMAIL"))
    assert_predicate employee, :employee?
    assert_predicate manager, :manager?
    assert employee.authenticate(variables.fetch("ONAYFLOW_DEMO_EMPLOYEE_PASSWORD"))
    assert manager.authenticate(variables.fetch("ONAYFLOW_DEMO_MANAGER_PASSWORD"))
  end

  private

  def provisioner(variables)
    ProductionDemoProvisioner.new(
      environment: ActiveSupport::StringInquirer.new("production"),
      variables: variables
    )
  end

  def valid_variables
    {
      "ONAYFLOW_ALLOW_PRODUCTION_DEMO" => "true",
      "ONAYFLOW_DEMO_EMPLOYEE_EMAIL" => "presentation.employee@onayflow.test",
      "ONAYFLOW_DEMO_EMPLOYEE_PASSWORD" => "EmployeeDemo-Only-2026!",
      "ONAYFLOW_DEMO_MANAGER_EMAIL" => "presentation.manager@onayflow.test",
      "ONAYFLOW_DEMO_MANAGER_PASSWORD" => "ManagerDemo-Only-2026!"
    }
  end
end
