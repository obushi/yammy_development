class Dish < ActiveRecord::Base

	has_many :menus
	has_many :meals, :through => :menus
	accepts_nested_attributes_for :menus

end
