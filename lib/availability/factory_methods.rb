module Availability
  module FactoryMethods
    def create(**args)
      cls = args.delete(:event_class) || Availability::subclass_for(args.delete(:frequency) || :daily)
      raise ArgumentError, "undefined frequency" if cls.nil?
      cls.send :new, **args
    end

    def once(**args)
      Once.create **args
    end

    %w{day week month year}.each do |suffix|
      frequency = suffix == 'day' ? :daily : :"#{suffix}ly"
      cls = Availability::subclass_for(frequency)

      define_method frequency do |**args|
        args[:interval] ||= 1 unless args[:interval]
        cls.create **args
      end

      {
        :"every_#{suffix}"        => 1,
        :"every_other_#{suffix}"  => 2,
        :"every_two_#{suffix}s"   => 2,
        :"every_three_#{suffix}s" => 3,
        :"every_four_#{suffix}s"  => 4,
        :"every_five_#{suffix}s"  => 5
      }.each do |method_name, interval|
        define_method method_name do |**args|
          cls.send(frequency, **args, interval: interval)
        end
      end
    end
  end
  extend FactoryMethods
end
