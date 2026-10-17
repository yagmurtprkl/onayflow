if Rails.env.production?
  puts "Demo accounts are not created in production."
else
  demo_accounts = [
    {
      name: "Demo Çalışan",
      email: "employee@onayflow.test",
      role: :employee,
      password: "Demo123!"
    },
    {
      name: "Demo Yönetici",
      email: "manager@onayflow.test",
      role: :manager,
      password: "Demo123!"
    }
  ]

  demo_accounts.each do |attributes|
    user = User.find_or_initialize_by(email: attributes[:email])
    user.assign_attributes(attributes)
    user.password_confirmation = attributes[:password]
    user.save!
  end

  puts "Demo-only OnayFlow accounts are ready. Do not use them in production."
end
