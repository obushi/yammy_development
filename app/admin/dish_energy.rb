ActiveAdmin.register DishEnergy do

  menu priority: 2

  config.filters = false
  actions :all, :except => [:new, :edit]

  index do
    column :id
    column :name
    column :kilo_calorie
    column :meal_id
    actions
  end

end
