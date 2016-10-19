class AddTitleDeckToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :title, :text
    add_column :documents, :deck, :text
  end
end
