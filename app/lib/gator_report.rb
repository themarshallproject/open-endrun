class GatorReport
	include ApplicationHelper	

	def self.weekly
		user_ids = UserPostAssignment.pluck(:user_id).uniq.sort
		
		users = User.where(id: user_ids).all

		start_date = 7.days.ago
		end_date = 1.minute.ago

		users.map{ |user|
			{ 
				email: user.email,
				count: user.taggings
					.where('created_at > ?', start_date)
					.where('created_at < ?', end_date)
					.count
			}
		}.sort_by{ |obj|
			-1 * obj[:count]
		}.map{|obj|
			[obj[:count], obj[:email]].join("\t")
		}.join("\n")

	end
	
	def self.tmp_links_per_day
		(Newsletter.published.first.created_at.to_date..Newsletter.published.last.created_at.to_date).flat_map{ |date|
			newsletters = Newsletter.where('published_at > ?', date.beginning_of_day).where('published_at < ?', date.end_of_day)
			data = newsletters.map{ |newsletter|
				
				hrefs = self.get_newsletter_link_hrefs(newsletter)

				tmp_hrefs = hrefs.select{|href|
					href.include?('themarshallproject.org')
				}

				[
					date.strftime('%Y-%m-%d'),
					"id_#{newsletter.id}",
					newsletter.published_at.strftime('%Y-%m-%d %H:%M:%S'),
					tmp_hrefs.count,
					hrefs.count,
					newsletter.published?,
				]
			}


			if newsletters.empty?
				data = [[
					date.strftime('%Y-%m-%d'),
					nil,
					nil,
					nil,
					nil,
					nil,
				]]
			end
			data
		}.map{|row| row.join("\t") }.join("\n")
	end

	def self.get_newsletter_link_hrefs(newsletter)
		newsletter.item_assignments.flat_map{ |assignment|
			if assignment.taggable.present?
				Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(
					assignment.taggable.email_content
				).html_safe
			end
		}.compact.flat_map{|html|
			Nokogiri::HTML.fragment(html).css('a').map{|el|
				el['href']
			}
		}
	end

end