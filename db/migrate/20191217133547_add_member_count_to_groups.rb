class AddMemberCountToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :members_count, :integer, null: false, default: 0
    change_column_default :groups, :members_count, nil
  end
end
