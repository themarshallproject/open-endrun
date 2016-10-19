namespace :export do
	task markdown: :environment do 
		photo_ids = []
		posts = Post.published.all.map do |post|
			post_photos = post.content.scan(/\[photo (.+?)\]/).map{ |match|
				args = match[0].split(' ').map{|arg| arg.split('=') }.inject({}){|obj, (k, v)| obj[k]=v;obj }
				args['id'].to_i
			}

			photo_ids << post_photos

			{
				id: post.id,
				slug: post.slug,
				title: post.title,
				deck: post.deck,
				markdown: post.content
			}
		end

		photos = Photo.where(id: photo_ids.flatten).map do |photo|
			{
				id: photo.id,
				caption: photo.caption,
				original_url: photo.original_url,
				sizes: photo.sizes
			}
		end

		puts JSON.pretty_generate({
			posts: posts,
			photos: photos
		})
	end
end
