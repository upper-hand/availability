module RecurringEvent
  module Createable
    def create(**args)
      frequency = name.split(':').last.downcase.to_sym
      super **args.merge(frequency: frequency)
    end
  end
end
