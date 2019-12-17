class GmemberAsTrusteeAndTruster < ActiveRecord::Migration[5.2]
  def change
    Trust.delete_all
    remove_column :trusts, :trustee_id
    remove_column :trusts, :truster_id

    add_reference(:trusts, :trustee, index: true, foreign_key: { to_table: :group_memberships }, null: false)
    add_reference(:trusts, :truster, index: true, foreign_key: { to_table: :group_memberships }, null: false)

    GroupMembership.delete_all
    add_column :group_memberships, :status, :string, null: false
  end
end
