require 'has_custom_fields'

module HasCustomFields
  
  def HasCustomFields.insert
    unless ActiveRecord::Base.included_modules.include?(HasCustomFields::InstanceMethods)
      ActiveRecord::Base.extend HasCustomFields::ClassMethods
      ActiveRecord::Base.send :include, HasCustomFields::InstanceMethods
    end
  end

  if defined?(::Rails::Railtie)
    require "rails"
    
    class Railtie < Rails::Railtie
      initializer "has_custom_fields.extend_active_record" do
        ActiveSupport.on_load(:active_record) do
          HasCustomFields.insert
        end
      end
    end
  else
    HasCustomFields.insert
  end
end
