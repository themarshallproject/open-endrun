class RenameFeaturedImageForTags < ActiveRecord::Migration
  def change
    rename_column :tags, :featured_image_id, :featured_photo_id
  end
end
