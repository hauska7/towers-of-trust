class LotsOfChanges < ActiveRecord::Migration[5.2]
  def change
    drop_table :participations
    drop_table :meetings
    remove_column :users, :city_id
    drop_table :cities

    add_column :users, :votes_count, :integer, null: false

    create_table :votes do |t|
      t.string :status, null: false
      t.datetime :expired_at

      t.timestamps
    end
    add_reference(:votes, :voter, index: true, foreign_key: { to_table: :users }, null: false)
    add_reference(:votes, :person, index: true, foreign_key: { to_table: :users }, null: false)
  end
end
