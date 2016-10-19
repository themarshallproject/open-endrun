class AddShorttokenToLinks < ActiveRecord::Migration
  def change
    add_column :links, :short_token, :string
    add_index :links, :short_token
  end
end
