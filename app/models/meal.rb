class Meal < ActiveRecord::Base

  has_many :dish_energies
	accepts_nested_attributes_for :dish_energies

	has_many :voters
	accepts_nested_attributes_for :voters

	has_many :menus
	accepts_nested_attributes_for :menus

	has_many :users, :through => :voters
	has_many :dishes, :through => :menus

end