module HasFields
  class Engine < Rails::Engine
    isolate_namespace HasFields
  
    config.to_prepare do
      unless ActiveRecord::Base.included_modules.include?(HasFields::InstanceMethods)
        ActiveRecord::Base.extend HasFields::ClassMethods
        ActiveRecord::Base.send :include, HasFields::InstanceMethods
      end
    end
  end
end