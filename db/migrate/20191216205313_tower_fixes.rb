class TowerFixes < ActiveRecord::Migration[5.2]
  def change
    add_column :group_memberships, :color, :string, null: false, default: "invalid"
    GroupMembership.all.each do |membership|
      membership.set_color X.generate_color
      membership.save!
    end
    change_column_default :group_memberships, :color, nil

    remove_column :users, :color
  end
end
