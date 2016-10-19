class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.text :url
      t.text :title
      t.integer :creator_id
      t.text :content

      t.timestamps
    end
    add_index :links, :creator_id
  end
end
