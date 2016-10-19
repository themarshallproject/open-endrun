class ChangeIdToStringForNewsletters < ActiveRecord::Migration
  def change
  	change_column :newsletters, :mailchimp_id, :string
  end
end
