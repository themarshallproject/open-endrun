class AddFeaturedImageToTags < ActiveRecord::Migration
  def change
    add_column :tags, :featured_image_id, :integer
  end
end
