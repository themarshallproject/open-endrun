class ChangeBylineColumnToTextOnNewsletters < ActiveRecord::Migration
  def change
  	change_column :newsletters, :byline, :text
  end
end
