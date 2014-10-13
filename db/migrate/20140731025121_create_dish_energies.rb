class CreateDishEnergies < ActiveRecord::Migration
  def change
    create_table :dish_energies do |t|
      t.string :name
      t.integer :kilo_calorie
      t.references :meal, :null => false

      t.timestamps
    end
  end
end
