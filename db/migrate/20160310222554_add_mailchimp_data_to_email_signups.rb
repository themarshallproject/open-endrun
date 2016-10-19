class AddMailchimpDataToEmailSignups < ActiveRecord::Migration
  def change
    add_column :email_signups, :mailchimp_data, :text
  end
end
