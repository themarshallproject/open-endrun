class AddAspectRatioToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :aspect_ratio, :decimal
  end
end
