require 'active_model'
require 'active_model/validations'

class ReferenceModel
  class ValidationError < StandardError; end

  include ActiveModel::Model
  include ActiveModel::Validations

  class << self
    def count
      @count ||= 0
    end # class method count

    attr_writer :count

    def next_id
      @next_id ||= -1
      @next_id += 1
    end # class method next_id
  end # class << self

  def [] attribute
    self.send attribute
  rescue NoMethodError
    nil
  end # method []

  def initialize *args
    super

    @id = self.class.next_id
  end # method initialize

  attr_reader :id

  def assign_attributes attributes
    attributes.each do |attribute, value|
      self.send(:"#{attribute}=", value)
    end # each
  end # method assign_attributes

  def persisted?
    @persisted ||= false
  end # method persisted

  def reload
    restore_attributes

    self
  end # method reload

  def save *args
    opts = args.extract_options!

    if !opts.fetch(:validate, true) || valid?
      self.class.count += 1
      persist_attributes
      @persisted = true
      true
    else
      false
    end # if-else
  end # method save

  def save! *args
    raise ValidationError.new "Unable to persist #{self.class.name}" unless save(*args)
  end # method save!

  def update_attributes attributes
    assign_attributes attributes
    save
  end # method update_attributes

  private

  def persist_attributes
    @persisted_attributes = {}.tap do |hsh|
      (instance_variables - [:@errors, :@id, :@persisted, :@validation_context]).each do |attribute|
        hsh[attribute] = instance_variable_get(attribute)
      end # each
    end # tap
  end # method persist_attributes

  def restore_attributes
    return if @persisted_attributes.nil?

    @persisted_attributes.each do |attribute, value|
      instance_variable_set attribute, value
    end # each
  end # method restore_attributes
end # class
