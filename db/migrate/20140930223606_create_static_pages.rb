class CreateStaticPages < ActiveRecord::Migration
  def change
    create_table :static_pages do |t|
      t.string :slug
      t.text :content

      t.timestamps
    end
    add_index :static_pages, :slug
  end
end
