class AddSouceAndSlugToAssetFile < ActiveRecord::Migration
  def change
    add_column :asset_files, :slug, :string
    add_index :asset_files, :slug
    add_column :asset_files, :source, :string
    add_index :asset_files, :source
  end
end
