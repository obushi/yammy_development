ActiveAdmin.register Dish do

  menu priority: 4

  config.filters = false
  actions :all, :except => [:new, :edit]

  index do
    column :id
    column :name
    actions
  end


end
