class AddColorToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :color, :string, null: true
    User.all.each do |user|
      user.set_color X.generate_color
      user.save!
    end
  end
end
