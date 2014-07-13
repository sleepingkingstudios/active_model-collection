# lib/active_model/collection.rb

require 'active_model'
require 'active_support/inflector'

module ActiveModel
  class Collection
    include Enumerable
    include ActiveModel::Validations

    class << self
      def create args
        validate_arguments_for_create! args
        collection = new
        collection.send :build, args
        collection.save
        collection
      end # class method create

      def create! args
        validate_arguments_for_create! args
        collection = new
        collection.send :build, args
        collection.save!
        collection
      end # class method create!

      attr_reader :model

      def model= klass
        klass = klass.constantize if klass.is_a?(String) || klass.is_a?(Symbol)
 
        if @model
          raise StandardError.new 'model is already set'
        elsif klass.is_a?(Class)
          @model = klass
        else
          raise ArgumentError.new 'model must be a Class or the name of a Class'
        end # if-elsif-else
      end # class method model=

      private

      def validate_arguments_for_create! args
        if !args.respond_to?(:each)
          raise ArgumentError.new 'expected array of params hashes or model objects'
        elsif args.empty?
          raise ArgumentError.new 'expected non-empty array'
        end # if
      end # class method validate_arguments_for_create!
    end # class << self

    delegate :each, :to => :@records

    def initialize args = []
      if args.blank?
        @records = []
      elsif !args.respond_to?(:inject)
        raise ArgumentError.new 'expected array of params hashes or model objects'
      elsif args.inject(true) { |memo, arg| memo && arg.is_a?(self.class.model) }
        @records = args.dup
      else
        build args
      end # if-else
    end # method initialize

    def save *args
      opts = args.extract_options!
 
      return false unless valid? || opts.fetch(:validate, nil) == false
 
      @records.inject(true) { |memo, record| memo && record.save(opts) }
    end # method save

    def save! *args
      opts = args.extract_options!

      raise validation_error unless valid? || opts.fetch(:validate, nil) == false

      @records.map { |record| record.save! opts }
    end # method save

    def update_attributes args
      if !args.respond_to?(:each)
        raise ArgumentError.new 'expected array of params hashes'
      elsif args.blank?
        raise ArgumentError.new 'expected non-empty array'
      elsif count != args.count
        raise ArgumentError.new "expected #{count} params, received #{args.count}"
      end # if

      # Update the attributes on the record objects.
      @records.each.with_index do |record, index|
        params = args[index]
        params.each { |attribute, value| record.send "#{attribute}=", value }
      end # each

      save
    end # method update_attributes

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

    def build args
      @records = args.map { |params| self.class.model.new params }
    end # method build
 
    def validate_record record
      record.valid?
    end # method validate_record
 
    def validate_records
      @records.inject(true) { |memo, record| memo && validate_record(record) }
    end # method validate_records

    def validation_error
      messages = errors.full_messages
      @records.each { |record| messages.concat record.errors.full_messages }
      StandardError.new 'Unable to persist collection because of the ' +
        'following errors: ' + messages.join(',')
    end # method validation_error
  end # class
end # module
