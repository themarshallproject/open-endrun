class AddLogBlobToEmailSignups < ActiveRecord::Migration
  def change
    add_column :email_signups, :log_blob, :text
  end
end
