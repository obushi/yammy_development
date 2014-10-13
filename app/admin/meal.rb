ActiveAdmin.register Meal do

  menu priority: 1
  actions :all, :except => [:new]

  permit_params :id, :date, :period, :energy, :protein, :fat, :carbohydrate, :salt, :created_at, :updated_at

  index do
    column :id
    column :date
    column :period do |m|
      case m.period
        when 'breakfast'
          '朝'
        when 'lunch'
          '昼'
        when 'dinner'
          '夜'
        else
          '不明'
      end
    end

    column :dishes do |m|
      link_to '献立を見る', admin_dish_energies_path + '?q[meal_id_eq]=' + m.id.to_s
    end
    column :energy
    column :salt
    column :protein
    column :carbohydrate
    column :fat
    actions
  end

  filter :date

end