class User < ActiveRecord::Base

	has_many :voters
	has_many :meals, :through => :voters
	accepts_nested_attributes_for :voters

end
