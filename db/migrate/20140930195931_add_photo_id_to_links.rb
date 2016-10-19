class AddPhotoIdToLinks < ActiveRecord::Migration
  def change
    add_column :links, :photo_id, :integer
    add_index :links, :photo_id
  end
end
