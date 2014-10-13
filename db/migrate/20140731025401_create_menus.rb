class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
      t.references :meal, :null => false
      t.references :dish, :null => false

      t.timestamps
    end
  end
end
