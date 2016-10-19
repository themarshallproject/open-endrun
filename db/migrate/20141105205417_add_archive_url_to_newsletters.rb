class AddArchiveUrlToNewsletters < ActiveRecord::Migration
  def change
    add_column :newsletters, :archive_url, :string
  end
end
