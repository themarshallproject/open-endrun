class AddPhotoFlagToYahooPosts < ActiveRecord::Migration
  def change
    add_column :yahoo_posts, :lead_photo, :boolean
  end
end
