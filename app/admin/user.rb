ActiveAdmin.register User do

  menu priority: 3

  config.filters = false
  actions :all, :except => [:new, :edit]

  index do
    column :id
    column :token
    column :last_access
    actions
  end


end
