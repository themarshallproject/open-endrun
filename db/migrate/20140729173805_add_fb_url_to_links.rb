class AddFbUrlToLinks < ActiveRecord::Migration
  def change
    add_column :links, :fb_image_url, :text
  end
end
