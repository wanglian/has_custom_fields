require 'has_custom_fields'

module HasCustomFields
  
  class Railtie < Rails::Railtie
    def self.insert
      ActiveRecord::Base.extend HasCustomFields::ClassMethods
      ActiveRecord::Base.send :include, HasCustomFields::InstanceMethods
    end
  end

  if defined?(::Rails::Railtie)
    require "rails"
    
    class Railtie < Rails::Railtie
      initializer "has_custom_fields.extend_active_record" do
        ActiveSupport.on_load(:active_record) do
          HasCustomFields::Railtie.insert
        end
      end
    end
  else
    Railtie.insert
  end
end
