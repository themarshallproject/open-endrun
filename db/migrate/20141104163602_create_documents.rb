class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :dc_id
      t.boolean :published
      t.text :body
      t.text :dc_data
      t.text :dc_published_url

      t.timestamps
    end
    add_index :documents, :dc_id
    add_index :documents, :published
  end
end
