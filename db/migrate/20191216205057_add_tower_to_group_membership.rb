class AddTowerToGroupMembership < ActiveRecord::Migration[5.2]
  def change
    add_reference(:group_memberships, :tower, index: true, foreign_key: { to_table: :group_memberships }, null: true)
  end
end
