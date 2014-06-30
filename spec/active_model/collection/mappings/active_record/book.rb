# spec/active_model/collection/mappings/active_record/book.rb

class Book < ActiveRecord::Base
  validates :isbn, :presence => true
end # class
