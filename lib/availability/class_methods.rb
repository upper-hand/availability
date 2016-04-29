module Availability
  module ClassMethods
    def availability?(thing)
      AbstractAvailability === thing
    end

    def beginning
      @@beginning ||= Date.new(1970, 1, 1)
    end

    def default_args
      {}
    end

    def subclass_for(frequency)
      Availability.const_get frequency.to_s.capitalize rescue nil
    end
  end
  extend ClassMethods
end
