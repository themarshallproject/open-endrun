class CreateFeaturedBlockActivateEvents < ActiveRecord::Migration
  def change
    create_table :featured_block_activate_events do |t|
      t.integer :featured_block_id
      t.integer :user_id
      t.text :snapshot

      t.timestamps
    end
    add_index :featured_block_activate_events, :created_at
    add_index :featured_block_activate_events, :featured_block_id
    add_index :featured_block_activate_events, :user_id
  end
end
