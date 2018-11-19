class CreateTables < ActiveRecord::Migration[5.2]
  def change
    create_table :cities do |t|
      t.string :name
      t.string :state
      t.string :country

      t.timestamps
    end
    add_reference(:cities, :user, index: true, foreign_key: true, null: false)

    create_table :meetings do |t|
      t.timestamps
    end
    add_reference(:meetings, :city, index: true, foreign_key: true, null: false)

    create_table :participations do |t|
      t.timestamps
    end
    add_reference(:participations, :meeting, index: true, foreign_key: true, null: false)
    add_reference(:participations, :user, index: true, foreign_key: true, null: false)
  end
end
