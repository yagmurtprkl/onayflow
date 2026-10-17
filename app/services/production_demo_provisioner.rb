class ProductionDemoProvisioner
  class ConfigurationError < StandardError; end

  MINIMUM_PASSWORD_LENGTH = 16
  OPT_IN_KEY = "ONAYFLOW_ALLOW_PRODUCTION_DEMO"
  ACCOUNT_CONFIGURATION = {
    employee: {
      name: "OnayFlow Demo Employee",
      email_key: "ONAYFLOW_DEMO_EMPLOYEE_EMAIL",
      password_key: "ONAYFLOW_DEMO_EMPLOYEE_PASSWORD"
    },
    manager: {
      name: "OnayFlow Demo Manager",
      email_key: "ONAYFLOW_DEMO_MANAGER_EMAIL",
      password_key: "ONAYFLOW_DEMO_MANAGER_PASSWORD"
    }
  }.freeze

  def initialize(environment: Rails.env, variables: ENV)
    @environment = environment
    @variables = variables
  end

  def call!
    validate_configuration!

    User.transaction do
      ACCOUNT_CONFIGURATION.map do |role, configuration|
        provision_account(role, configuration)
      end
    end
  end

  private

  attr_reader :environment, :variables

  def validate_configuration!
    raise ConfigurationError, "Demo provisioning is production-only." unless environment.production?
    unless ActiveModel::Type::Boolean.new.cast(variables[OPT_IN_KEY])
      raise ConfigurationError, "Set #{OPT_IN_KEY}=true to provision production demo accounts."
    end

    missing_keys = credential_keys.select { |key| variables[key].blank? }
    if missing_keys.any?
      raise ConfigurationError, "Missing demo credential variables: #{missing_keys.join(', ')}"
    end

    passwords = ACCOUNT_CONFIGURATION.values.map { |config| variables.fetch(config[:password_key]) }
    if passwords.any? { |password| password.length < MINIMUM_PASSWORD_LENGTH }
      raise ConfigurationError, "Demo passwords must contain at least #{MINIMUM_PASSWORD_LENGTH} characters."
    end
    raise ConfigurationError, "Employee and manager demo passwords must differ." if passwords.uniq.one?
  end

  def credential_keys
    ACCOUNT_CONFIGURATION.values.flat_map { |config| config.values_at(:email_key, :password_key) }
  end

  def provision_account(role, configuration)
    password = variables.fetch(configuration[:password_key])
    user = User.find_or_initialize_by(email: variables.fetch(configuration[:email_key]))
    user.assign_attributes(
      name: configuration[:name],
      role: role,
      password: password,
      password_confirmation: password
    )
    user.save!
    user
  end
end
