module RecurringEvent
  module FactoryMethods
    def create(**args)
      frequency = args[:frequency] ||= :daily
      cls = RecurringEvent::subclass_for frequency
      raise ArgumentError, "undefined frequency" if cls.nil?
      cls.send :new, **args.merge(cls.default_args)
    end

    def once(**args)
      send(:_create, args, Once.default_args)
    end

    %w{day week month year}.each do |keyword|
      cls = RecurringEvent::subclass_for(keyword == 'day' ? :daily : :"#{keyword}ly")
      define_method "every_#{keyword}" do |**args|
        cls.send(:_create, args, interval: 1)
      end

      define_method "every_other_#{keyword}" do |**args|
        cls.send(:_create, args, interval: 2)
      end

      define_method "every_three_#{keyword}s" do |**args|
        cls.send(:_create, args, interval: 3)
      end

      define_method "every_four_#{keyword}s" do |**args|
        cls.send(:_create, args, interval: 4)
      end

      define_method "every_five_#{keyword}s" do |**args|
        cls.send(:_create, args, interval: 5)
      end
    end

    alias_method :daily, :every_day
    alias_method :weekly, :every_week
    alias_method :monthly, :every_month
    alias_method :yearly, :every_year

    def _create(args, **overriding_args)
      options = {}.merge(args).merge(overriding_args)
      create **options
    end
    private :_create
  end
  extend FactoryMethods
end
