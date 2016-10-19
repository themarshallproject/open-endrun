class AddOptionsToEmailSignups < ActiveRecord::Migration
  def change
    add_column :email_signups, :options_on_create, :text
  end
end
