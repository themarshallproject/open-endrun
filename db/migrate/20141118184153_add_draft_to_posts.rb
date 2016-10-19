class AddDraftToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :serialized_draft, :text
  end
end
