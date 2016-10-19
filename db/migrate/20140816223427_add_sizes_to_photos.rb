class AddSizesToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :sizes, :hstore
    add_index  :photos, :sizes, using: :gin
  end
end
