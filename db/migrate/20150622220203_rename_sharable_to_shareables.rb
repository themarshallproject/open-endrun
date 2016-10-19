class RenameSharableToShareables < ActiveRecord::Migration
  def change
  	rename_table :post_sharables, :post_shareables
  end
end
