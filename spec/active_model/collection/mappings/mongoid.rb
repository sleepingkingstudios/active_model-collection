# spec/active_model/collection/mappings/mongoid.rb

begin
  require 'mongoid'

  Mongoid.load_configuration({
    sessions: {
      default: {
        database: 'active_model_collection_test',
        hosts: ['localhost:27017']
      }
    }
  })

  Dir[File.dirname(__FILE__) + "/mongoid/**/*.rb"].each { |file| require file }
rescue LoadError
end
