class CreateGraphics < ActiveRecord::Migration
  def change
    create_table :graphics do |t|
      t.string :slug
      t.text :html
      t.text :head

      t.timestamps
    end
    add_index :graphics, :slug
  end
end
