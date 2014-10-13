ActiveAdmin.register Menu do

  menu priority: 6

  config.filters = false
  actions :all

  index do
    column :id
    column :meal_id
    column :dish_id
    actions
  end


end
