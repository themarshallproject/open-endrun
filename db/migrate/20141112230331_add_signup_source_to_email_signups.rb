class AddSignupSourceToEmailSignups < ActiveRecord::Migration
  def change
    add_column :email_signups, :signup_source, :string
  end
end
