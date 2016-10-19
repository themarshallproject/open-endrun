class FreeformStreamPromo < ActiveRecord::Base

	scope :published, -> do 
		where(published: true).where("revised_at < ?", Time.now) 
	end

	scope :stream, -> (min_time, max_time) do
		published.where('revised_at < ?', max_time)
		         .where('revised_at > ?', min_time)
	end

	def stream_sort_key
		revised_at
	end

end