class AddPublishedToFreeformStreamPromos < ActiveRecord::Migration
  def change
    add_column :freeform_stream_promos, :published, :boolean
    add_index :freeform_stream_promos, :published
  end
end
