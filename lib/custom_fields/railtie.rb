module CustomFields
  if defined?(Rails::Railtie)
    require "rails"
    
    class Railtie < Rails::Railtie
      initializer "has_custom_fields.extend_active_record" do
        ActiveSupport.on_load(:active_record) do
          CustomFields::Railtie.insert
        end
      end
    end
  end
  
  class Railtie
    def self.insert
      ActiveRecord::Base.send(:include, ActiveRecord::Has::CustomFields)
    end
  end
end