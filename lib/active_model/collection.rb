# lib/active_model/collection.rb

require 'active_model'
require 'active_model/validations'
require 'active_support/inflector'

module ActiveModel
  class Collection
    include Enumerable
    include ActiveModel::Validations

    class << self
      attr_reader :model

      def model=(klass)
        klass = klass.constantize if klass.is_a?(String) || klass.is_a?(Symbol)
 
        if @model
          raise StandardError.new('model is already set')
        elsif klass.is_a?(Class)
          @model = klass
        else
          raise ArgumentError.new('model must be a Class or the name of a Class')
        end # if-elsif-else
      end # class method model=
    end # class << self

    delegate :each, :to => :@records

    def initialize(*args)
      if args.blank?
        @records = []
      else
        build *args
      end # if-else
    end # method initialize

    def build(first, *rest)
      args = [first, *rest]
 
      @records = args.map { |params| self.class.model.new params }
    end # method build

    def save(*args)
      opts = args.extract_options!
 
      return false unless valid? || opts.fetch(:validate, nil) == false
 
      @records.inject(true) { |memo, record| memo && record.save(opts) }
    end # method save

    def valid?
      valid = super()
 
      if @records.blank?
        errors[:records] << "can't be blank"
        valid = false
      else
        valid &&= validate_records
      end # if-else
 
      valid
    end # method valid?
 
    private
 
    def validate_record(record)
      record.valid?
    end # method validate_record
 
    def validate_records
      @records.inject(true) { |memo, record| memo && validate_record(record) }
    end # mthod validate_records
  end # class
end # module
