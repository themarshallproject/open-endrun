class CreatePostDeployTokens < ActiveRecord::Migration
  def change
    create_table :post_deploy_tokens do |t|
      t.integer :post_id
      t.text :label
      t.text :token
      t.boolean :active

      t.timestamps null: false
    end
    add_index :post_deploy_tokens, :post_id
  end
end
