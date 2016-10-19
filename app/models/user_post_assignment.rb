class UserPostAssignment < ActiveRecord::Base
	belongs_to :post, touch: true
	belongs_to :user, touch: true
	validates_presence_of :post
	validates_presence_of :user
end
