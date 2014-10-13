class Voter < ActiveRecord::Base

	belongs_to :meal
	belongs_to :user

end
