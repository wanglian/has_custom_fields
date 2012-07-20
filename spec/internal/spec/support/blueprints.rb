require 'machinist/active_record'

Advisor.blueprint do
  name { "Jim #{sn}"}
end

Organization.blueprint do
  name { "Org #{sn}"}
end

User.blueprint do
  name { "user #{sn}" }
  organization { Organization.make! }
end

Field.blueprint do
  organization_id { (Organization.make!).id }
  name { "Value" }
  style { "text" }
  kind { "User" }
end