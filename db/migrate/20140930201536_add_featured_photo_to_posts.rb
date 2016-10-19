class AddFeaturedPhotoToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :featured_photo_id, :integer
    add_index :posts, :featured_photo_id
  end
end
