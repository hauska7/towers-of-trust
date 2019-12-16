class VoteInGroups < ActiveRecord::Migration[5.2]
  def change
    Vote.delete_all
    add_reference(:votes, :group, index: true, foreign_key: { to_table: :groups }, null: false)
  end
end
