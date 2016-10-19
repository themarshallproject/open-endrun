class AddIndexToAnonOnLetters < ActiveRecord::Migration
  def change
  	add_index :letters, :is_anonymous
  end
end
