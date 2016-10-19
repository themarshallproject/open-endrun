class AddViaGatorToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :via_gator, :boolean
    add_index :photos, :via_gator
  end
end
