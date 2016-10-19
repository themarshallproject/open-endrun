class CreateFreeformStreamPromos < ActiveRecord::Migration
  def change
    create_table :freeform_stream_promos do |t|
      t.text :slug
      t.text :html
      t.datetime :revised_at
      t.string :deploy_token

      t.timestamps null: false
    end
    add_index :freeform_stream_promos, :slug
    add_index :freeform_stream_promos, :deploy_token
  end
end
