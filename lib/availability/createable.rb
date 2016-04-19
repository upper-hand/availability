module Availability
  module Createable
    def create(**args)
      frequency = name.split(':').last.downcase.to_sym
      super **args.merge(frequency: frequency, event_class: self)
    end
  end
end
