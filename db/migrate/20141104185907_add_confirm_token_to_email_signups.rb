class AddConfirmTokenToEmailSignups < ActiveRecord::Migration
  def change
    add_column :email_signups, :confirm_token, :string
    add_index :email_signups, :confirm_token
  end
end
