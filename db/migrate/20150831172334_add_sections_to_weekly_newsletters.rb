class AddSectionsToWeeklyNewsletters < ActiveRecord::Migration
  def change
    add_column :weekly_newsletters, :tmp_stories, :text
    add_column :weekly_newsletters, :other_stories, :text
  end
end
