class AddOriginalContentToLetters < ActiveRecord::Migration
  def change
    add_column :letters, :original_content, :text
  end
end
