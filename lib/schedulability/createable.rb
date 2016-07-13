module Schedulability
  module Createable
    def self.extended(base)
      base.public_class_method :new
    end

    def create(**args)
      frequency = name.split(':').last.downcase.to_sym
      super **args.merge(event_class: self)
    end
  end
end
