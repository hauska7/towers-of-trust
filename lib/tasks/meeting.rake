namespace :meeting do
  task :add_users => :environment do
    city = City.where(name: "Poznan").first!

    10.times do |i|
      user= User.build(full_name: "Jas#{i}", password: "123456", email: "jas#{i}@email.com")
      user.city = city
      user.save!
    end
  end

  task :create => :environment do
    City.all.each do |city|
      users = User.active_and_in_city(city_id: city.id).to_a
      users.shuffle!

      groups = []
      while !users.empty? do
        groups << users.shift(5)
      end
      if groups.size > 1 && groups.last.size < 3
        groups.first.concat(groups.last)
        groups.delete_at(-1)
      end

      puts "groups:"
      require 'pp'
      pp groups

      if groups.first.size == 1
        # no meeting is possible
      else
        groups.each do |group|
          meeting = Meeting.build(users: group, city: city)
          meeting.save!
        end
      end
    end
  end
end

