class CreateFeaturedBlocks < ActiveRecord::Migration
  def change
    create_table :featured_blocks do |t|
      t.string :template
      t.text :slots
      t.boolean :published

      t.timestamps
    end
    add_index :featured_blocks, :published
  end
end
