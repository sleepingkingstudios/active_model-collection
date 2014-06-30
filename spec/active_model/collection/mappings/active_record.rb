# spec/active_model/collection/mappings/active_record.rb

begin
  require 'active_support'
  require 'active_model/validator'
  require 'active_model/validations'
  require 'active_model/validations/callbacks'
  require 'active_model/validations/presence'
  require 'active_record'

  ActiveRecord::Base.logger = Logger.new(STDERR)

  ActiveRecord::Base.establish_connection(
    :adapter  => "sqlite3",
    :database => ":memory:"
  )

  ActiveRecord::Schema.define do
    create_table :books do |table|
      table.column :isbn,     :integer
      table.column :synopsis, :string
    end
  end

  ActiveRecord::Base.logger.level = 2

  Dir[File.dirname(__FILE__) + "/active_record/**/*.rb"].each { |file| require file }
rescue LoadError
end
