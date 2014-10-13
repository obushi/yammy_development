ActiveAdmin.register Voter do

  menu priority: 5

  config.filters = false
  actions :all

  index do
    column :id
    column :user_id
    column :meal_id
    actions
  end


end
