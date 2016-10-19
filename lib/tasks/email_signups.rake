namespace :email_signups do
  desc "TODO"

  task sync_from_mailchimp: :environment do
    EmailSignup.all.shuffle.each do |email_signup|
      puts "email_signups:sync_from_mailchimp email=#{email_signup.email}"
      email_signup.pull_mailchimp_member_info
    end
  end

end
