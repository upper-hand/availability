require_relative 'abstract_availability'

module Availability
  class Once < AbstractAvailability
    extend Createable

    def initialize(**args)
      raise ArgumentError, "start_time is required" unless args.has_key?(:start_time)
      raise ArgumentError, "duration is required" unless args.has_key?(:duration)
      super **args, interval: 0, stops_by: args[:start_time] + args[:duration]
    end

    def interval_difference(this, that)
      raise NotImplementedError.new('not supported')
    end

    def move_by(time, amount)
      time + amount.days
    end

    def last_occurrence
      start_time
    end

    def next_occurrence(time)
      start_time
    end

    def residue_for(time)
      0
    end
  end
end
