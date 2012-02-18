require 'has_custom_fields'

module HasCustomFields
  if defined?(Rails::Railtie)
    require "rails"
    
    class Railtie < Rails::Railtie
      initializer "has_custom_fields.extend_active_record" do
        ActiveSupport.on_load(:active_record) do
          HasCustomFields::Railtie.insert
        end
      end
    end
  end
  
  class Railtie
    def self.insert
      ActiveRecord::Base.send(:include, ActiveRecord::HasCustomFields)
    end
  end
end
