class AddBookmarkletTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bookmarklet_token, :string
    add_index :users, :bookmarklet_token
  end
end
