class VoteToTrust < ActiveRecord::Migration[5.2]
  def change
    rename_table :votes, :trusts
    rename_column :trusts, :person_id, :trustee_id
    rename_column :trusts, :voter_id, :truster_id
  end
end
