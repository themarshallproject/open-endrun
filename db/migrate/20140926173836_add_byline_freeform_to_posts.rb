class AddBylineFreeformToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :byline_freeform, :text
  end
end
