class AddStreamPromoToPost < ActiveRecord::Migration
  def change
    add_column :posts, :stream_promo, :string
    add_index :posts, :stream_promo
  end
end
