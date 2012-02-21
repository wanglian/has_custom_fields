HasCustomFields
========================

HasCustomFields provides you with a way to have multiple scoped dynamic key value,
attribute stores persisted in the database for any given model.  These are also
known as the Entity-Attribute-Value model (EAV).


Installation
------------------------

In your Gemfile:

    gem "has_custom_fields"

Do a bundle install, then for each model you want to have custom fields (say User
with an organization scope for the fields and attributes) do the following:

    $ rails generate has_custom_fields_generator User organization

Then check and run the generated migration

    $ rake db:migrate

Then add the has_custom_fields class method to your model:

    class User < ActiveRecord::Base
      has_custom_fields :scopes => [:organization]
    end

For Rails 2.x users please depend on the 0.0.5 version of the gem


Description
-------------------------  

### What is Entity-attribute-value model?

Entity-attribute-value model (EAV) is a data model that is used in circumstances 
where the number of attributes (properties, parameters) that can be used to describe 
a thing (an "entity" or "object") is potentially very vast, but the number that will 
actually apply to a given entity is relatively modest.


Typical Problem
-------------------------

Say you have a contact management system, and each person in the database belongs
to an organisation.  That organization may have a bunch of values that need to be
stored in the database, such as, primary contact name, or hot prospect?

Each of these could be stored as column values on the organization table, but
you could have 10-20 of these, and adding a new one would require a database change.

HasCustomFields allows you to define these key values simply with an attribute
type.


Example
-------------------------

Following on from the installation section above, we have a User with the following
custom fields setting:

    class User < ActiveRecord::Base
      has_custom_fields :scopes => [:organization]
    end

We can now find the custom fields for the organization.

    @organization = @user.organization
    @organization_fields = User.custom_field_fields(:organization, @organization.id)

This returns an array full of UserFields that will look something like:

    UserField id: 104, name: "High Potential", style: "checkbox", select_options: nil

Which could then be rendered out into a HTML page like so (logic in HTML for demonstration purposes, would be better to do this as a helper method)

    <% @organization_fields.each do |field| %>
      <p>
      <% case field.style %>
      <% when 'checkbox' %>
        <%= f.check_box field.name %>
      <% when 'text' %>
        <%= f.text_field field.name, @user.custom_fields[:organization][@organization.id]['High Potential'] %>
      <% end %>
      </p>
    <% end %>

Running the Specs
========================

Ruby Environment
------------------------

You should run the unit tests under ruby-1.9.2, a sample .rvmrc would be:

  $ cat .rvmrc
  rvm ruby-1.9.2@has_custom_fields --create

Once you have the right ruby, you should bundle install.  Running the specs then
is done with:

  $ rake spec

Creating the test database
------------------------

The test databases will be created from the info specified in spec/db/database.yml.
Either change that file to match your database or change your database to
match that file.

Copyright (c) 2008 Marcus Wyatt, released under the MIT license