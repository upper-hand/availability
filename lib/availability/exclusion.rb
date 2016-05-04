module Availability
  class Exclusion
    def self.after_day(date)
      raise ArgumentError, "invalid date" if date.nil?
      new Rule::AfterDate.new(date.to_date)
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

    def self.before_time(time)
      raise ArgumentError, "invalid time" if time.nil?
      new Rule::BeforeTime.new(time.to_time)
    end

    def initialize(rule)
      @rule = rule
    end

    def violated_by?(time)
      @rule.violated_by? time
    end

    private
    module Rule
      class AfterDate
        def initialize(date)
          @date = date
        end

        def violated_by?(time)
          time.to_date > @date
        end
      end

      class AfterTime
        def initialize(date_or_time)
          @compare_to = date_or_time.to_time
        end

        def violated_by?(time)
          time.to_time.seconds_since_midnight > @compare_to.to_time.seconds_since_midnight
        end
      end

      class BeforeDate
        def initialize(date)
          @date = date
        end

        def violated_by?(time)
          time.to_date < @date
        end
      end

      class BeforeTime
        def initialize(date_or_time)
          @compare_to = date_or_time.to_time
        end

        def violated_by?(time)
          time.to_time.seconds_since_midnight < @compare_to.to_time.seconds_since_midnight
        end
      end

      class OnDate
        def initialize(date)
          @date = date
        end

        def violated_by?(time)
          time.to_date == @date
        end
      end
    end
  end
end
