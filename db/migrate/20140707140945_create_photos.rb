class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.text :original_url
      t.text :caption
      t.text :byline

      t.timestamps
    end
    add_index :photos, :original_url
    add_index :photos, :caption
    add_index :photos, :byline
  end
end
