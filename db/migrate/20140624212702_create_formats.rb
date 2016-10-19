class CreateFormats < ActiveRecord::Migration
  def change
    create_table :formats do |t|
      t.string :name
      t.string :slug

      t.timestamps
    end
    add_index :formats, :name
    add_index :formats, :slug
  end
end
