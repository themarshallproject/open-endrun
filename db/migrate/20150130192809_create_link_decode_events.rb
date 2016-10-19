class CreateLinkDecodeEvents < ActiveRecord::Migration
  def change
    create_table :link_decode_events do |t|
      t.integer :link_id
      t.text :cookies
      t.string :placement

      t.timestamps null: false
    end
    add_index :link_decode_events, :link_id
  end
end
