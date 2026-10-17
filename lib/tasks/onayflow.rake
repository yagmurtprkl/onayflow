namespace :onayflow do
  desc "Prepare idempotent development data for the priority dashboard"
  task prepare_priority_demo: :environment do
    documents = DevelopmentPriorityDemoPreparer.new.call!
    puts "Prepared #{documents.size} OnayFlow priority demo documents:"
    documents.each do |document|
      puts "- #{document.title} (#{document.next_action_priority}, due #{document.due_at.iso8601})"
    end
  rescue DevelopmentPriorityDemoPreparer::EnvironmentError,
         DevelopmentPriorityDemoPreparer::AccountError,
         DevelopmentPriorityDemoPreparer::DocumentStateError => error
    abort error.message
  end

  desc "Provision production demo accounts from temporary secret environment variables"
  task provision_demo: :environment do
    users = ProductionDemoProvisioner.new.call!
    puts "Provisioned #{users.size} OnayFlow production demo accounts. Passwords were not printed."
  rescue ProductionDemoProvisioner::ConfigurationError => error
    abort error.message
  end
end
