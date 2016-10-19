class AddLeadPhotoToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :lead_photo_id, :integer
  end
end
