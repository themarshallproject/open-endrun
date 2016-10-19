class ChangeFormatsToPostFormats < ActiveRecord::Migration
  def change
  	rename_table :formats, :post_formats
  end
end
