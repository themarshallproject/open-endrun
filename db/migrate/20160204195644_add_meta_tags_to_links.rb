class AddMetaTagsToLinks < ActiveRecord::Migration
  def change
    add_column :links, :html_meta_json, :text
  end
end
