class CreatePostPublishedEvents < ActiveRecord::Migration
  def change
    create_table :post_published_events do |t|
      t.integer :post_id

      t.timestamps null: false
    end
    add_index :post_published_events, :post_id
  end
end
