class GmemberTowerChanges < ActiveRecord::Migration[5.2]
  def change
    rename_column :group_memberships, :tower_id, :tower_top_id
    add_reference(:group_memberships, :trustee, index: true, foreign_key: { to_table: :group_memberships }, null: true)
  end
end
