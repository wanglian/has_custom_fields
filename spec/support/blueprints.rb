require 'machinist/active_record'



Organization.blueprint do
  name { "Org #{sn}"}
end

User.blueprint do
  name { "user #{sn}" }
  organization { Organization.make! }
end