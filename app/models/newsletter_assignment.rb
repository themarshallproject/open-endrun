class NewsletterAssignment < ActiveRecord::Base
	belongs_to :newsletter, touch: true
	validates_presence_of :newsletter

	belongs_to :taggable, polymorphic: true, touch: true
    validates_presence_of :taggable

end