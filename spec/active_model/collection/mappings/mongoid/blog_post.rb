# spec/active_model/collection/mappings/mongoid/blog_post.rb

class BlogPost
  include Mongoid::Document

  field :index, :type => Integer
  field :title, :type => String

  validates :index, :presence => true
end # class
