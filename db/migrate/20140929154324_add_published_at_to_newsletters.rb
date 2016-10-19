class AddPublishedAtToNewsletters < ActiveRecord::Migration
  def change
    add_column :newsletters, :published_at, :datetime
    add_index :newsletters, :published_at
  end
end
