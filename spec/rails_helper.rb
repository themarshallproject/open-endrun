# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

require 'capybara/rspec'
require 'capybara/rails'
require 'capybara-screenshot/rspec'

require 'capybara/poltergeist'
Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new(app, {
    inspector: true,
    js_errors: true,
  })
end
Capybara.javascript_driver = :poltergeist_debug


# save to CircleCI's artifacts directory if we're on CircleCI
require 'simplecov'
if ENV['CIRCLE_ARTIFACTS']
  dir = File.join(ENV['CIRCLE_ARTIFACTS'], "coverage")
  SimpleCov.coverage_dir(dir)
end
SimpleCov.start

# keep tests sealed to network
# require 'webmock/rspec'
# WebMock.disable_net_connect!(allow_localhost: true)

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil
  def self.connection
    @@shared_connection || retrieve_connection
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
# end shared_connection AR hack


# TKTK extract this?
skip_endpoint = "http://localhost:9999"
ENV['LOVESTORY_V2_BOOT_ENDPOINT'] = skip_endpoint
ENV['LOVESTORY_V3_ENDPOINT'] = skip_endpoint
ENV['LOVESTORY_WEBSOCKET_HOST'] = skip_endpoint
ENV['LOVESTORY_RT'] = skip_endpoint
ENV['LOVESTORY_BQ'] = skip_endpoint
ENV['LOVESTORY_SI'] = skip_endpoint

ENV['POST_PUBLISHED_ALERT_EMAILS'] = "published-post@test.com"
ENV['URL_BASE'] = "http://endrun.dev"

ENV['ELASTICSEARCH_VAR'] = "ES_TEST"
ENV['ES_TEST'] = "http://localhost:9200"
$redis = ConnectionPool.new(size: 5, timeout: 5) do
  Redis.new(url: "redis://127.0.0.1:6379")
end

require 'sidekiq/testing'
Sidekiq::Testing.disable!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# http://www.railsonmaui.com/blog/2013/08/06/migrating-from-capybara-webkit-to-poltergeist-phantomjs/

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.include Rails.application.routes.url_helpers
  config.include Capybara::DSL
  config.include FactoryGirl::Syntax::Methods

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false
  config.order = :random

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs

  config.infer_spec_type_from_file_location!
end

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
