class AddRefererToLinkDecodeEvents < ActiveRecord::Migration
  def change
    add_column :link_decode_events, :referer, :text
  end
end
