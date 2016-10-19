class DonateController < ApplicationController

	layout 'public'

	def form
	end

	def charge

		logger.info "donate#charge #{params[:donate].except(:stripeToken).to_json}"

		@endrun_customer = StripeCustomer.create(
			first_name:     params[:donate][:first_name],
			last_name:      params[:donate][:last_name],
			email:          params[:donate][:email],
			address1:       params[:donate][:address1],
			address2:       params[:donate][:address2],
			phone:          params[:donate][:phone],
			city:           params[:donate][:city],
			state:          params[:donate][:state],
			zip:            params[:donate][:zip],
			donation_type:  params[:donate][:donation_type],
			plan:           params[:donate][:plan],
			amount:         params[:donate][:amount],
			custom_amount:  params[:donate][:custom_amount],
			inbound_source: params[:donate][:inbound_via]
		)

		@stripe_metadata = {
			first_name:     params[:donate][:first_name],
			last_name:      params[:donate][:last_name],
			email:          params[:donate][:email],
			address1:       params[:donate][:address1],
			address2:       params[:donate][:address2],
			phone:          params[:donate][:phone],
			city:           params[:donate][:city],
			state:          params[:donate][:state],
			zip:            params[:donate][:zip],
		}

		if params[:donate][:donation_type] == 'recurring'
			create_recurring(params)
		elsif params[:donate][:donation_type] == 'charge'
			create_charge(params)
		else
			# what now?
		end

	rescue ::Stripe::CardError => e
		redirect_to e.message
	end

	def create_charge(params)

		Stripe.api_key = ENV['STRIPE_SECRET_KEY']

		custom_amount = params[:donate][:custom_amount] # params[:donate][:amount] is dollars
		if custom_amount.present?
			@cents = dollars_to_cents(custom_amount)
		else
			@cents = dollars_to_cents(params[:donate][:amount])
		end

		token = params[:donate][:stripeToken]
		email = params[:donate][:email]

		logger.info "process_donation (charge) -- #{email} #{@cents}cents"

		@customer = Stripe::Customer.create(
			email: email,
			card:  token,
			metadata: @stripe_metadata
		)

		@charge = Stripe::Charge.create(
			customer: @customer.id,
			amount: @cents,
			description: "One-time donation from #{email}",
			currency: 'usd',
			metadata: @stripe_metadata
		)

		@endrun_customer.stripe_customer_id = @customer.id
		@endrun_customer.save

		DebugEmailWorker.perform_async({
			from: 'ivong@themarshallproject.org',
			to: 'ivong+donation@themarshallproject.org',
			subject: "[#{ENV['RACK_ENV']}] Donation",
			text_body: JSON.pretty_generate({
				params: params[:donate].except(:stripeToken)
			})
		})

	end

	def create_recurring(params)
		Stripe.api_key = ENV['STRIPE_SECRET_KEY']

		token = params[:donate][:stripeToken]
		email = params[:donate][:email]
		plan  = params[:donate][:plan]

		logger.info "process_donation (recurring) -- #{email} #{plan}"

		@customer = Stripe::Customer.create(
			card: token,
			plan: plan,
			email: email,
			metadata: @stripe_metadata
		)

		@endrun_customer.stripe_customer_id = @customer.id
		@endrun_customer.save
	end

	def dollars_to_cents(dollars_string)
		cleaned = (dollars_string || "")
			.gsub(/^\$/, "") # remove leading "$"
			.gsub(/,/, "")   # remove any ","
		return 100 * cleaned.to_i # make cents
	end

end
