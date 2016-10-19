class CreateAssetFiles < ActiveRecord::Migration
  def change
    create_table :asset_files do |t|
      t.integer :asset_id
      t.string :s3_bucket
      t.text :s3_key

      t.timestamps null: false
    end
    add_index :asset_files, :asset_id
    add_index :asset_files, :s3_bucket
    add_index :asset_files, :s3_key
  end
end
