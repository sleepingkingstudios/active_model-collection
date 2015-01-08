# active_model-collection.gemspec

require File.expand_path "lib/active_model/collection/version"

Gem::Specification.new do |gem|
  gem.name        = 'active_model-collection'
  gem.version     = ActiveModel::Collection::VERSION
  gem.date        = Time.now.utc.strftime "%Y-%m-%d"
  gem.summary     = 'Collection class for ActiveModel objects.'
  gem.description = <<-DESCRIPTION
    A utility class that handles bulk operations on a collection of ActiveModel
    objects as if it was a single ActiveModel object, e.g. a record or
    document. Intended as a solution to handling bulk create or update
    operations in a Rails application. For more information, check out the
    README.
  DESCRIPTION
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'

  gem.require_path = 'lib'
  gem.files        = Dir["lib/**/*.rb", "LICENSE", "*.md"]
  gem.test_files   = Dir["gemfiles/*.gemfile", "spec/**/*.rb"]

  gem.add_runtime_dependency 'activemodel',   '~> 4.1'
  gem.add_runtime_dependency 'activesupport', '~> 4.1'

  gem.add_development_dependency 'rake',                        '~> 10.3'
  gem.add_development_dependency 'rspec',                       '~> 3.1'
  gem.add_development_dependency 'rspec-collection_matchers',   '~> 1.0'
  gem.add_development_dependency 'rspec-sleeping_king_studios', '>= 2.0.0.rc.0'
  gem.add_development_dependency 'factory_girl',                '~> 4.2'
  gem.add_development_dependency 'pry',                         '~> 0.9', '>= 0.9.12'
  gem.add_development_dependency 'appraisal'
end # gemspec
