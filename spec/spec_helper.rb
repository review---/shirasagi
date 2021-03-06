require 'simplecov'
require 'coveralls'
Coveralls.wear!

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require File.expand_path(__FILE__, "../../app/helpers")
require 'rspec/rails'
#require 'rspec/autorun'
require 'capybara/rspec'
require 'capybara/rails'
require 'database_cleaner'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter 'spec/'
  add_filter 'vendor/bundle'
end

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
#  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
#  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  #config.order = "random"
  config.order = "order"

  config.include Rails.application.routes.url_helpers
  config.include Capybara::DSL

  config.include FactoryGirl::Syntax::Methods
  config.before do
    FactoryGirl.reload
  end

  config.filter_run_excluding(mecab: true) unless can_test_mecab_spec?
  config.filter_run_excluding(open_jtalk: true) unless can_test_open_jtalk_spec?
  config.filter_run_excluding(ldap: true) unless can_test_ldap_spec?

  config.before(:suite) do
    # `rake db:drop`
    ::Mongoid::Sessions.default.drop
    # `rake db:create_indexes`
    ::Rails.application.eager_load!
    ::Mongoid::Tasks::Database.create_indexes

    #
    DatabaseCleaner[:mongoid].strategy = :truncation
  end

  config.add_setting :default_dbscope, default: :context
  config.extend(SS::DatabaseCleanerSupport)
end

def unique_id
  Time.now.to_f.to_s.delete('.').to_i.to_s(36)
end
