# spec/active_model/collection/spec_helper.rb

require 'rspec'
require 'rspec/collection_matchers'
require 'rspec/sleeping_king_studios/all'
require 'factory_girl'
require 'pry'

# Require Factories, Custom Matchers, &c
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |file| require file }

# Require ORM/ODM libraries, if supported
Dir[File.dirname(__FILE__) + "/mappings/*.rb"].each { |file| require file }

# Miscellaneous library configuration
I18n.enforce_available_locales = true

RSpec.configure do |config|
  # Limit a spec run to individual examples or groups by tagging them with
  # `:focus` metadata.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  Kernel.srand config.seed

  # Alias "it should behave like" to 2.13-like syntax.
  config.alias_it_should_behave_like_to 'expect_behavior', 'has behavior'

  # rspec-expectations config goes here.
  config.expect_with :rspec do |expectations|
    # Enable only the newer, non-monkey-patching expect syntax.
    expectations.syntax = :expect
  end # expect_with

  # rspec-mocks config goes here.
  config.mock_with :rspec do |mocks|
    # Enable only the newer, non-monkey-patching expect syntax.
    mocks.syntax = :expect

    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended.
    mocks.verify_partial_doubles = true
  end # mock_with
end # config
