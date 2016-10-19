class AddLoginTokenDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :login_token_expires, :datetime
  end
end
