class MoveVotesCount < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :votes_count
    add_column :group_memberships, :trust_count, :integer, null: false, default: 0
    change_column_default :group_memberships, :trust_count, nil
  end
end
