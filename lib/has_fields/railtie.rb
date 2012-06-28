require 'has_fields'

module HasFields
  
  def HasFields.insert
    unless ActiveRecord::Base.included_modules.include?(HasFields::InstanceMethods)
      ActiveRecord::Base.extend HasFields::ClassMethods
      ActiveRecord::Base.send :include, HasFields::InstanceMethods
    end
  end

  if defined?(::Rails::Railtie)
    require "rails"
    
    class Railtie < Rails::Railtie
      initializer "has_fields.extend_active_record" do
        ActiveSupport.on_load(:active_record) do
          HasFields.insert
        end
      end
    end
  else
    HasFields.insert
  end
end
