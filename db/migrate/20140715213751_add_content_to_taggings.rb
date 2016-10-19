class AddContentToTaggings < ActiveRecord::Migration
  def change
    add_column :taggings, :content, :string
  end
end
