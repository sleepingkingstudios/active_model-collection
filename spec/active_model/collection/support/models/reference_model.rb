require 'active_model'
require 'active_model/validations'

class ReferenceModel
  include ActiveModel::Model
  include ActiveModel::Validations

  class << self
    def count
      @count ||= 0
    end # class method count

    attr_writer :count
  end # class << self

  def save(*args)
    opts = args.extract_options!

    if !opts.fetch(:validate, true) || valid?
      self.class.count += 1
      true
    else
      false
    end
  end # method save
end # class
