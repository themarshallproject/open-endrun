class AddWebIdToNewsletters < ActiveRecord::Migration
  def change
    add_column :newsletters, :mailchimp_web_id, :string
  end
end
