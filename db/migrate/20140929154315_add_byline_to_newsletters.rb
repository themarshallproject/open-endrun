class AddBylineToNewsletters < ActiveRecord::Migration
  def change
    add_column :newsletters, :byline, :string
  end
end
