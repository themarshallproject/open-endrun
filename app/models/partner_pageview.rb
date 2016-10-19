class PartnerPageview < ActiveRecord::Base
	belongs_to :post
	belongs_to :partner
end
