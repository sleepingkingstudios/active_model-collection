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

    delegate :each, :empty?, :to => :@records

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

    def assign_attributes args
      case args
      when Array
        assign_attributes_from_array args
      when Hash
        assign_attributes_from_hash args
      else
        raise ArgumentError.new 'expected array or hash of params hashes'
      end # case
    end # method assign_attributes

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
      assign_attributes args

      save
    end # method update_attributes
    alias_method :update, :update_attributes

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

    def assign_attributes_from_array args
      if count != args.count
        raise ArgumentError.new "expected #{count} params, received #{args.count}"
      end # if

      @records.each.with_index do |record, index|
        attributes = args[index]

        record.assign_attributes(attributes)
      end # each
    end # method assign_attributes_from_array

    def assign_attributes_from_hash hsh
      raise ArgumentError.new "attributes hash keys can't be blank" if hsh.key?(nil) || hsh.key?('')

      records_hash = {}

      @records.each do |record|
        record_key = extract_key(record)

        if records_hash.key?(record_key)
          raise StandardError.new "records with duplicate key #{record_key.inspect}"
        end # if

        records_hash[record_key] = record
      end # each

      extra_keys = hsh.keys - records_hash.keys

      unless extra_keys.empty?
        raise ArgumentError.new "expected to update models, but were not found"\
          " in collection -- missing keys #{extra_keys.map(&:inspect).join ', '}"\
          " (#{extra_keys.count} total)"
      end # unless

      hsh.each do |key, attributes|
        record = records_hash[key]
        record.assign_attributes attributes
      end # each
    end # method assign_attributes_from_hash

    def build args
      @records = args.map { |params| self.class.model.new params }
    end # method build

    def extract_key record
      record.id
    end # method extract_key

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
