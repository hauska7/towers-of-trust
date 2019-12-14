class AddGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_reference(:groups, :moderator, index: true, foreign_key: { to_table: :users }, null: false)

    create_table :group_memberships do |t|
      t.timestamps
    end
    add_reference(:group_memberships, :member, index: true, foreign_key: { to_table: :users }, null: false)
    add_reference(:group_memberships, :group, index: true, foreign_key: { to_table: :groups }, null: false)
  end
end
