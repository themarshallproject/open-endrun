class AddMailchimpIdToEmailSignups < ActiveRecord::Migration
  def change
    add_column :email_signups, :mailchimp_id, :string
    add_index :email_signups, :mailchimp_id
  end
end
