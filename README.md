# ActiveModel::Collection [![Build Status](https://travis-ci.org/sleepingkingstudios/active_model-collection.svg?branch=master)](https://travis-ci.org/sleepingkingstudios/active_model-collection)

A utility class that handles bulk operations on a collection of ActiveModel
objects as if it was a single ActiveModel object, e.g. a record or document.
Intended as a solution to handling bulk create or update operations in a Rails
application. For more information, check out the README.

## Installation

    gem install active_record-collection

## Contribute

- https://github.com/sleepingkingstudios/rspec-sleeping_king_studios

Hi, I'm Rob Smith, a Ruby Engineer and the developer of this library. I use these tools every day, but they're not just written for me. If you find this project helpful in your own work, or if you have any questions, suggestions or critiques, please feel free to get in touch! I can be reached on GitHub (see above, and feel encouraged to submit bug reports or merge requests there) or via email at `merlin@sleepingkingstudios.com`. I look forward to hearing from you!

## Supported ORMs/ODMs

ActiveModel::Collection is currently tested against ActiveRecord 4 (using a SQLite database) and Mongoid 4. Support for ActiveRecord 3 and Mongoid 3 is planned for the future. If you would like to see ActiveModel::Collection tested against another ORM or ODM, feel free to get in touch.

## How To Use

First, set up your database/datastore and models. For this example, we are using ActiveRecord to set up a Books model with three columns. On a proper Ruby on Rails application, you would instead create a migration to create the database table.

    ActiveRecord::Schema.define do
      create_table :books do |table|
        table.column :isbn,     :integer
        table.column :title,    :string
        table.column :synopsis, :text
      end
    end

    class Book < ActiveRecord::Base
      validates :isbn,  :presence => true
      validates :title, :presence => false
    end

Next, create your collection class. Make sure to set the class's `model` property to your created model. For Rails applications I recommend creating a directory at app/models/collections in which to define your collections.

    class BooksCollection < ActiveModel::Collection
      self.model = Book
    end

Set up your view to support multiple model objects on the form.

Finally, on your controller you can use the collection in create/update operations as if it was a single ActiveRecord object.

    class BooksController < ApplicationController
      before_action :build_books, :only => %i(new create)
      before_action :find_books,  :only => %i(edit update)

      def create
        if @books.save
          redirect_to :index
        else
          render :new
        end
      end

      def update
        if @books.update books_params
          redirect_to :index
        else
          render :edit
        end
      end

      private

      def books_params
        case params[:books]
        when Array
          params[:books]
        when Hash
          params[:books].values
        else
          []
        end
      end

      def build_books
        @books = BooksCollection.new books_params
      end

      def find_books
        @books = BooksCollection.new(Book.find params[:books].keys)
      end
    end
