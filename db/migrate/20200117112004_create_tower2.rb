class CreateTower2 < ActiveRecord::Migration[5.2]
  def change
    towers = []
    GroupMembership.all.each do |gmember|
      towers << gmember if gmember.tower_top == gmember
    end
    towers.map! do |gm|
      tower = X.factory.build("tower")
      tower.set_name(X.generate_tower_name)
      tower.group = gm.group
      tower.owner = gm
      tower.save!
      { gmember_id: gm.id, tower: tower }
    end


    GroupMembership.all.each do |gmember|
      if gmember.tower_top
        tower = towers.find { |t| t[:gmember_id] == gmember.tower_top_id }
        gmember.tower = tower[:tower]
        gmember.save!
      end
    end

    X.services.clean_up("all")

    remove_column :group_memberships, :tower_top_id
  end
end
