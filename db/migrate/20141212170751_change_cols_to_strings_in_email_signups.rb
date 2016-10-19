class ChangeColsToStringsInEmailSignups < ActiveRecord::Migration
  def change
  	change_column :email_signups, :q_work_in_criminal_justice, :string
  	change_column :email_signups, :q_is_journalist, :string
  	change_column :email_signups, :q_incarcerated, :string
  end
end
