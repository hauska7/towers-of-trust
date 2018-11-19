class AddCityToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference(:users, :city, index: true, foreign_key: true, null: true)
  end
end
