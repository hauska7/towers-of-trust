class CreateTower < ActiveRecord::Migration[5.2]
  def change
    create_table :towers do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_reference(:towers, :group, index: true, foreign_key: { to_table: :groups }, null: false)
    add_reference(:towers, :owner, index: true, foreign_key: { to_table: :group_memberships }, null: false)
    ActiveRecord::Base.connection.execute("ALTER TABLE group_memberships DROP CONSTRAINT fk_rails_86c2eb1d79")
    add_reference(:group_memberships, :tower, index: true, foreign_key: { to_table: :towers }, null: true)
  end
end
