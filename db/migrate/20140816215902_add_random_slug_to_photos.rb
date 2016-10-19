class AddRandomSlugToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :random_slug, :string
    add_index :photos, :random_slug
  end
end
