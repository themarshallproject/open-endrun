class AddSlugsToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :slugs, :hstore
    add_index :posts, :slugs, using: :gin
  end
end
