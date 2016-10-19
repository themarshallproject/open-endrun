class AddVisitsFromIpsToMembers < ActiveRecord::Migration
  def change
    add_column :members, :visits_from_ips, :text
  end
end
