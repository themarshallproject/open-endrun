class AddLoginTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :login_token, :string
    add_index :users, :login_token
  end
end
