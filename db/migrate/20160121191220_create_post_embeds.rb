class CreatePostEmbeds < ActiveRecord::Migration
  def change
    create_table :post_embeds do |t|
      t.string :embed_type
      t.integer :embed_id
      t.integer :post_id

      t.timestamps null: false
    end
    add_index :post_embeds, :embed_type
    add_index :post_embeds, :embed_id
    add_index :post_embeds, :post_id
  end
end
