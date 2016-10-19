class AddSlugAndNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :slug, :string
    add_index :users, :slug
    add_column :users, :name, :string
  end
end
