class AddFieldsToEmailSignups < ActiveRecord::Migration
  def change
    add_column :email_signups, :first_name, :string
    add_column :email_signups, :last_name, :string
    add_column :email_signups, :q_work_in_criminal_justice, :boolean
    add_column :email_signups, :q_is_journalist, :boolean
    add_column :email_signups, :q_incarcerated, :boolean
    add_column :email_signups, :email_format, :string
  end
end
