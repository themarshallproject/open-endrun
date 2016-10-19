class ProjectNextToDie

	def slug
		"next-to-die"
	end

	def render_html(fragment: nil)
		@fragment = fragment.to_s.downcase.gsub(/[^-a-z0-9]/, '')

		if @fragment.present?
			html = state()
		else
			html = index()
		end

		return html
	end

	def lookup_description(state_slug)
		rows = %Q{
			al	52 percent of people on its death row prisoners are minorities.
			az	In 2014, Joseph Wood struggled for two hours during his botched execution. 
			fl	The law allows either lethal injection or the electric chair.
			ga	In 1972, a Georgia case prompted the U.S. Supreme Court to deem the death penalty unconstitutional. Four years later, a Georgia case birthed the modern death penalty.
			mo	It executes more people per capita than any other state
			oh	It's the only state where an execution has failed.
			ok	A pathologist in Oklahoma invented the three-step lethal injection protocol. Will it be used again?
			tx	The state's executions have declined since adopting a life without parole alternative in 2005.
			va	The number is dwindling.
		}
		data = rows.split("\n").select{ |row| 
			row.strip.length > 5 
		}.inject({}) { |obj, row| 
			slug, description = row.strip.split("\t")
			obj[slug.strip.downcase] = description
			obj
		}
		data[state_slug.downcase] || ""
	end

	def index
		template_url = 'https://tmp-knell-app-production.s3.amazonaws.com/index.html'
		template = Rails.cache.fetch('next_to_die_index', expires_in: 10, race_condition_ttl: 10) do 
			HTTParty.get(template_url).body
		end

		return template
	end

	def state
		template_url = 'https://tmp-knell-app-production.s3.amazonaws.com/state.html'
		template = Rails.cache.fetch('next_to_die_state', expires_in: 10, race_condition_ttl: 10) do 
			HTTParty.get(template_url).body
		end

		state_slug = @fragment.downcase.gsub(/[^-a-z0-9]/, '')
		state_name = lookup_state_name(state_slug) || ''
		state_description = lookup_description(state_slug)

		template.gsub!("|*ENDRUN_INJECT_STATE_SLUG*|", state_slug)
		template.gsub!("|*ENDRUN_INJECT_STATE_NAME*|", state_name)
		template.gsub!("|*ENDRUN_INJECT_STATE_DESC*|", state_description)

		return template
	end

	#############################
	####### embed stuff #########
	#############################

	def render_embed_html(fragment: nil)
		@fragment = fragment.to_s.gsub(/[^-a-z0-9]/, '')

		if @fragment.present?
			html = embed_state()
		else
			html = embed_index()
		end

		return html
	end

	def embed_index
		template_url = 'https://tmp-knell-app-production.s3.amazonaws.com/embed.html'
		template = Rails.cache.fetch('next_to_die_embed_index', expires_in: 10, race_condition_ttl: 10) do 
			HTTParty.get(template_url).body
		end
		template.gsub("|*ENDRUN_INJECT_STATE_SLUG*|", 'index')
	end

	def embed_state
		template_url = 'https://tmp-knell-app-production.s3.amazonaws.com/embed-state.html'
		template = Rails.cache.fetch('next_to_die_embed_state', expires_in: 10, race_condition_ttl: 10) do 
			HTTParty.get(template_url).body
		end
		template.gsub("|*ENDRUN_INJECT_STATE_SLUG*|", @fragment)
	end

	####### case stuff

	def render_case_html(state_slug: '', case_slug: '')
		template_url = 'https://tmp-knell-app-production.s3.amazonaws.com/case.html'
		template = Rails.cache.fetch('next_to_die_case', expires_in: 10, race_condition_ttl: 10) do 
			HTTParty.get(template_url).body
		end

		state_slug = state_slug.downcase.gsub(/[^-a-z0-9]/, '') # whitelist allowed slug chars
		case_slug  =  case_slug.downcase.gsub(/[^-a-z0-9]/, '')
		
		template.gsub!("|*ENDRUN_INJECT_STATE_SLUG*|", state_slug)
		template.gsub!("|*ENDRUN_INJECT_CASE_SLUG*|", case_slug)
		
		return template
	end

	#############################
	#### helpers
	#############################

	def lookup_state_name(slug)
		stateLookup = JSON.parse('{"AL": "Alabama","AK": "Alaska","AZ": "Arizona","AR": "Arkansas","CA": "California","CO": "Colorado","CT": "Connecticut","DE": "Delaware","FL": "Florida","GA": "Georgia","HI": "Hawaii","ID": "Idaho","IL": "Illinois","IN": "Indiana","IA": "Iowa","KS": "Kansas","KY": "Kentucky","LA": "Louisiana","ME": "Maine","MD": "Maryland","MA": "Massachusetts","MI": "Michigan","MN": "Minnesota","MS": "Mississippi","MO": "Missouri","MT": "Montana","NE": "Nebraska","NV": "Nevada","NH": "New Hampshire","NJ": "New Jersey","NM": "New Mexico","NY": "New York","NC": "North Carolina","ND": "North Dakota","OH": "Ohio","OK": "Oklahoma","OR": "Oregon","PA": "Pennsylvania","RI": "Rhode Island","SC": "South Carolina","SD": "South Dakota","TN": "Tennessee","TX": "Texas","UT": "Utah","VT": "Vermont","VA": "Virginia","WA": "Washington","WV": "West Virginia","WI": "Wisconsin","WY": "Wyoming","DC": "Washington DC"}')
		return stateLookup[slug.upcase]
	end

end