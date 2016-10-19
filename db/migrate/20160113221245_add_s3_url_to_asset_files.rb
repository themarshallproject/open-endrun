class AddS3UrlToAssetFiles < ActiveRecord::Migration
  def change
    add_column :asset_files, :s3_url, :text
  end
end
