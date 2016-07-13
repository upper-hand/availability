module Availability
  class Exclusion < InstanceVariableComparability
    attr_reader :rule

    def self.after_day(date)
      raise ArgumentError, "invalid date" if date.nil?
      new Rule::AfterDate.new(date.to_date)
    end

    def self.after_date_and_time(time)
      raise ArgumentError, "invalid time" if time.nil?
      new Rule::AfterDateAndTime.new(time.to_time)
    end

    def self.after_time(time)
      raise ArgumentError, "invalid time" if time.nil?
      new Rule::AfterTime.new(time.to_time)
    end

    def self.all_day(date)
      raise ArgumentError, "invalid date" if date.nil?
      new Rule::OnDate.new(date.to_date)
    end

    def self.before_day(date)
      raise ArgumentError, "invalid date" if date.nil?
      new Rule::BeforeDate.new(date.to_date)
    end

    def self.before_date_and_time(time)
      raise ArgumentError, "invalid time" if time.nil?
      new Rule::BeforeDateAndTime.new(time.to_time)
    end

    def self.before_time(time)
      raise ArgumentError, "invalid time" if time.nil?
      new Rule::BeforeTime.new(time.to_time)
    end

    def self.on_day_of_week(day_of_week) # 0=Sunday, 6=Saturday
      unless day_of_week.is_a?(Fixnum) && (0..6).include?(day_of_week)
        raise ArgumentError, "invalid day of week"
      end
      new Rule::OnDayOfWeek.new(day_of_week)
    end

    def initialize(rule)
      @rule = rule
    end

    def <=>(other)
      return 1 if other.nil?
      rule <=> other.rule
    end

    def violated_by?(time)
      @rule.violated_by? time
    end

    private
    module Rule
      class AfterDate < InstanceVariableComparability
        def initialize(date)
          @date = date
        end

        def violated_by?(time)
          time.to_date > @date
        end
      end

      class AfterDateAndTime < InstanceVariableComparability
        def initialize(time)
          @after_date = AfterDate.new time.to_date
          @after_time = AfterTime.new time
        end

        def violated_by?(time)
          @after_date.violated_by?(time) || @after_time.violated_by?(time)
        end
      end

      class AfterTime < InstanceVariableComparability
        def initialize(date_or_time)
          @compare_to = date_or_time.to_time
        end

        def violated_by?(time)
          time.to_time.seconds_since_midnight > @compare_to.to_time.seconds_since_midnight
        end
      end

      class BeforeDate < InstanceVariableComparability
        def initialize(date)
          @date = date
        end

        def violated_by?(time)
          time.to_date < @date
        end
      end

      class BeforeDateAndTime < InstanceVariableComparability
        def initialize(time)
          @before_date = BeforeDate.new time.to_date
          @before_time = BeforeTime.new time
        end

        def violated_by?(time)
          @before_date.violated_by?(time) || @before_time.violated_by?(time)
        end
      end

      class BeforeTime < InstanceVariableComparability
        def initialize(date_or_time)
          @compare_to = date_or_time.to_time
        end

        def violated_by?(time)
          time.to_time.seconds_since_midnight < @compare_to.to_time.seconds_since_midnight
        end
      end

      class OnDate < InstanceVariableComparability
        def initialize(date)
          @date = date
        end

        def violated_by?(time)
          time.to_date == @date
        end
      end

      class OnDayOfWeek < InstanceVariableComparability
        def initialize(day_of_week)
          @day_of_week = day_of_week
        end

        def violated_by?(time)
          time.wday == @day_of_week
        end
      end
    end
  end
end
