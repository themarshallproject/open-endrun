class AddDomainToLinks < ActiveRecord::Migration
  def change
    add_column :links, :domain, :string
    add_index :links, :domain
  end
end
