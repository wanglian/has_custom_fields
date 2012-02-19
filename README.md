HasCustomFields
========================

HasCustomFields provides you with a way to have multiple scoped dynamic key value,
attribute stores persisted in the database for any given model.  These are also
known as the Entity-Attribute-Value model (EAV).


Installation
------------------------

In your Gemfile:

    gem "has_custom_fields"

Do a bundle install, then for each model you want to have custom fields (say User) do
the following:

    $ rails generate has_custom_fields_generator User

Then check and run the generated migration

    $ rake db:migrate

Then add the has_custom_fields class method to your model:

    class User < ActiveRecord::Base
      has_custom_fields
    end

Description
-------------------------  

### What is Entity-attribute-value model?

Entity-attribute-value model (EAV) is a data model that is used in circumstances 
where the number of attributes (properties, parameters) that can be used to describe 
a thing (an "entity" or "object") is potentially very vast, but the number that will 
actually apply to a given entity is relatively modest.


### Typical Problem

Say you have a contact management system, and each person in the database belongs
to an organisation.  That organization may have a bunch of values that need to be
stored in the database, such as, primary contact name, or hot prospect?

Each of these could be stored as column values on the organization table, but
you could have 10-20 of these, and adding a new one would require a database change.

HasCustomFields allows you to define these key values simply with an attribute
type.

= Capabilities

The HasCustomFields plugin is capable of modeling this problem in a intuitive
way. Instead of having to deal with a related model you treat all attributes
(both on the model and related) as if they are all on the model. The plugin
will try to save all attributes to the model (normal ActiveRecord behavior)
but if there is no column for an attribute it will try to save it to a
related model whose purpose is to store these many sparsely populated
attributes.

The main design goals are:

* Have the eav attributes feel like normal attributes. Simple gets and sets
  will add and remove records from the related model.
* Allow for more than one related model. So for example on my User model I might
  have some eav behavior going into a contact_info table while others are
  going in a user_preferences table.
* Allow a model to determine what a valid eav attribute is for a given
  related model so our model still can generate a NoMethodError.

Example
=======

Will make the current class have eav behaviour.

  class Post < ActiveRecord::Base
    has_custom_field_behavior
  end
  post = Post.find_by_title 'hello world'
  puts "My post intro is: #{post.intro}"
  post.teaser = 'An awesome introduction to the blog'
  post.save

The above example should work even though "intro" and "teaser" are not
attributes on the Post model.

= RUNNING UNIT TESTS

== Ruby Environment

You should run the unit tests under ruby-1.9.2, a sample .rvmrc would be:

  $ cat .rvmrc
  rvm ruby-1.9.2@has_custom_fields --create

== Creating the test database

The test databases will be created from the info specified in test/database.yml.
Either change that file to match your database or change your database to
match that file.

== Running with Rake

The easiest way to run the unit tests is through Rake. By default sqlite3
will be the database run. Just change your env variable DB to be the database
adaptor (specified in database.yml) that you want to use. The database and
permissions must already be setup but the tables will be created for you
from schema.rb.

Copyright (c) 2008 Marcus Wyatt, released under the MIT license