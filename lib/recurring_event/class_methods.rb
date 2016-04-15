module RecurringEvent
  module ClassMethods
    def beginning
      @@beginning ||= Date.new(1970, 1, 1)
    end

    def default_args
      {}
    end

    def subclass_for(frequency)
      RecurringEvent.const_get frequency.to_s.capitalize rescue nil
    end
  end
  extend ClassMethods
end
