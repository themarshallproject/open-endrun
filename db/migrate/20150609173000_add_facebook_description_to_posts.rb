class AddFacebookDescriptionToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :facebook_description, :text
  end
end
