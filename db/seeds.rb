# coding: utf-8

require "csv"
dish_csv = CSV.read('db/dish.csv', {headers: true})
meal_csv = CSV.read('db/meal.csv', {headers: true})

last_meal_id = (Meal.last.nil? ? 0 : Meal.last.id)
updated = false
meal_csv.each do |row|
	meal = Meal.where(:date => row[1], :period => row[2]).first_or_initialize
	meal.new_record? ? updated = true : updated = false
	meal.update_attributes(
		:energy 	  => row[3],
		:protein	  => row[4],
		:fat 		  => row[5],
		:carbohydrate => row[6],
		:salt		  => row[7]
	)
end
p updated

# Tasks
# 1 dish.csvのmeals_id => meal.csvのidとひもづけ
# 2 meal.csvのdateとperiodをとってきてデータベースと照合
# 3 データベースからidをとってくる

dish_csv.each do |row|
	if updated
		DishEnergy.create(
			:name => row[1],
			:kilo_calorie => row[2],
			:meal_id => row[3].to_i + last_meal_id
		)
	end

	dish = Dish.where(name: row[1]).first_or_initialize
    dish.count = (dish.new_record? ? 1 : dish.count+1)
    dish.save
end

if updated
	meal_csv.each do |meal_row|
		meal_id = meal_row[0].to_i + last_meal_id
		if !Meal.where(:id => meal_id).first.nil?
			length = Meal.where(:id => meal_id).first.dish_energies.count

			for i in 0...length
				Menu.create(
					:meal_id => meal_id,
					:dish_id => Dish.where(:name => Meal.where(:id => meal_id).first.dish_energies[i].name).first.id
				)
			end
		end
	end
end


# Creates 100 users at once

# 100.times do |i|
# 	user = User.new
# 	user.token = SecureRandom.hex(8)
# 	# p user.token
# 	user.last_access = Time.now
# 	user.save
# 	p user
# end