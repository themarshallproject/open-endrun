source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails', '4.2.5.1'

gem 'pg', '~> 0.18.2'
gem 'puma', '~> 2.16'

gem 'redis', '~> 3.2.1'
gem 'foreman'
gem 'dotenv'

gem 'connection_pool'
gem 'dalli', '2.7.2'
gem 'rack-attack'

gem 'rails_12factor'

gem 'sinatra'

gem 'redcarpet', '3.2.3'
gem 'nokogiri'
gem 'mustache', "~> 1.0"

gem 'aws-sdk', '~> 1'
# gem 'aws-sdk', '~> 2'
gem 'httparty'
gem 'celluloid'

gem 'skylight', '0.10.2'
gem 'honeybadger', '~> 2.0.0', group: :production
gem 'newrelic_rpm', '~> 3.9.6.257', group: :production

gem 'sidekiq', '~> 3.4.2'
gem 'mini_magick', '3.8.1'
gem 'react-rails', '~> 1.0'

gem 'elasticsearch', '~> 1.0.6'

gem 'google-api-client', '0.7.1'

#gem 'sprockets-rails', '2.1.4'
gem 'bourbon', '3.2.3'
gem 'bitters'
gem 'neat'

gem 'bootstrap-sass', '3.2.0.2'
gem 'sass-rails'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'hashie'
gem 'diffy'

gem 'jwt'

gem 'postmark-rails', '~> 0.8.0'
gem 'mailchimp-api', '~> 2.0.5'

gem 'stripe', git: 'https://github.com/stripe/stripe-ruby'
gem 'archieml', git: 'https://github.com/themarshallproject/archieml-ruby'
gem 'googledoc_markdown', github: 'ivarvong/googledoc_markdown', tag: 'v0.1.1'

gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

gem 'bcrypt', '~> 3.1.7'

gem 'premailer'
gem 'premailer-rails'
gem 'css_parser'
gem 'roadie', '~> 3.1.1'

gem "letter_opener", :group => :development

group :development, :test do
  # gem 'webmock'
  gem 'simplecov', require: false
  gem 'factory_girl_rails', '~> 4.0'
  gem 'spring-commands-rspec'
  gem 'guard-rspec', require: false
  gem 'rspec-rails', '~> 3.0'
  gem 'capybara'
  gem 'database_cleaner'
  # gem 'capybara-webkit'
  gem 'selenium-webdriver'
  gem 'capybara-screenshot'
  gem 'poltergeist'
  gem 'rspec_junit_formatter', '0.2.2'
end

group :development do
  gem 'spring'
	gem 'metric_fu'
	gem 'flog'
	gem 'reek'
	gem 'flay'
	gem 'flamegraph'
  gem 'rubocop'
  gem "meta_request"
  gem 'quiet_assets'
  gem 'pry-rails'
	# gem 'rack-mini-profiler'
end
