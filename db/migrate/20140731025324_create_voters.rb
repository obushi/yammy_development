class CreateVoters < ActiveRecord::Migration
  def change
    create_table :voters do |t|
      t.references :user, :null => false, :default => 1
      t.references :meal, :null => false, :default => 1

      t.timestamps
    end
  end
end
