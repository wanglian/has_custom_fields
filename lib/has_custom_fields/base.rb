module HasCustomFields
  class Base < ActiveRecord::Base
    self.abstract_class = true
    serialize :select_options
    validates_presence_of :name,
      :message => 'Please specify the field name.'
    validates_presence_of :select_options_data,
      :if => "self.style.to_sym == :select",
      :message => "You must enter options for the selection, separated by commas."

    def select_options_data
      (self.select_options || []).join(",")
    end

    def select_options_data=(data)
      self.select_options = data.split(",").collect{|f| f.strip}
    end

    #scope :find_all_by_scope, lambda {|scope| {where("#{scope}_id = #{self.id}")}}
  end
end