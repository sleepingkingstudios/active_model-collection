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
        if @books.update params[:books]
          redirect_to :index
        else
          render :edit
        end
      end

      private

      def build_books
        @books = BooksCollection.new params[:books]
      end

      def find_books
        @books = BooksCollection.new(Book.find params[:books].keys)
      end
    end

## Handling Parameters

Because an `ActiveModel::Collection` can hold multiple model instances, passing in parameters to `::create` or `#update` is more complicated than passing in a simple attributes hash. The gem currently supports two ways to create or update multiple model instances at once: by passing in an array of attribute hashes, or by passing in a hash of attribute hashes (`#update` only).

### Arrays of Attributes Hashes

When creating one or more model instances through an `ActiveModel::Collection`, pass in an array of Hash instances, each of which contains the desired attributes for a model instance.

```
# Creating one model instance.
attributes = { 'title' => 'The Art of War', 'author' => 'Sun Tzu' }
book = Book.new(attributes)
#=> #<Book title: 'The Art Of War', author: 'Sun Tzu'>

# Creating multiple model instances.
attributes = [
  { 'title' => 'The Art of War', 'author' => 'Sun Tzu' },
  { 'title' => 'Vom Kriege',     'author' => 'von Clausewitz' },
  { 'title' => 'The Prince',     'author' => 'Niccolo Machiavelli' }
]
collection = BooksCollection.new(attributes)
books = collection.to_a
#=> [#<Book title: 'The Art Of War', author: 'Sun Tzu'>, #<Book title: 'Vom Kriege', author: 'von Clausewitz'>, #<Book title: 'The Prince', author: 'Niccolo Machiavelli'>]
```

You can also use an array of attribute hashes when updating a collection of model instances via the `#assign_attributes` or `#update` methods. However, when updating, the number of attribute hashes must match the number of model instances in the collection, and the order is important. The first model will be updated with the first attributes hash, the second model with the second hash, and so on.

### Hashes of Attributes Hashes

You can avoid concerns about ordering by passing in a hash of attibutes hashes to the `#assign_attributes` or `#update` methods. The key to the hash must be the `id` of the model instance to update, and the value must be a Has instance containing the desired attributes for that instance. The keys cannot be blank (nil or empty), and an error will be raised for any keys in the hash for which a corresponding model instance cannot be found in the collection.

```
# Updating multiple model instances.
attributes = {
  0: { isbn: 12345 },
  1: { isbn: 67890 }
}
collection = BooksCollection.new(Book.find attributes.keys)
collection.update_attributes attributes
books = collection.to_a
#=> [#<Book title: 'The Art Of War', author: 'Sun Tzu', isbn: 12345>, #<Book title: 'Vom Kriege', author: 'von Clausewitz', isbn: 67890>, #<Book title: 'The Prince', author: 'Niccolo Machiavelli'>]
```

Only the model instances referenced in the hash will be updated, even if the collection contains additional model instances.

You can also override the `#extract_key` method in `ActiveModel::Collection` to use a different hash key, such as a different attribute e.g. `email` or `title`, a combination of attributes or methods, or any other value based on the record. When overriding `#extract_key`, remember that the value cannot be blank (nil or empty) and must be unique to avoid errors when updating attributes.

```
# Overwriting the #extract_key method.
class BooksCollection < ActiveModel::Collection
  def extract_key(record)
    record.isbn
  end # method extract_key
end # class
```
