class AddMailchimpEuidLeidToEmailSignups < ActiveRecord::Migration
  def change
    add_column :email_signups, :mailchimp_euid, :string
    add_index :email_signups, :mailchimp_euid
    add_column :email_signups, :mailchimp_leid, :string
    add_index :email_signups, :mailchimp_leid
    add_column :email_signups, :mailchimp_is_active, :boolean
    add_index :email_signups, :mailchimp_is_active
  end
end
