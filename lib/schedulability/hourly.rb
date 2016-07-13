require_relative 'availability'
require_relative 'daily'

module Schedulability
  class Hourly < Daily
    extend Createable

    def interval_difference(this, that)
      first, second = [this, that].sort
      (second.to_i - first.to_i) / 1.hour
    end

    def move_by(time, amount)
      time + amount.hours
    end

    def includes?(time)
      return true if super
      return false if residue_for(time) != residue
      hours_on_same_day = next_n_occurrences(24, time).select {|t| t.wday == time.wday && t <= time }
      hours_on_same_day.none? {|hour| exclusions.any?{|excl| excl.violated_by? hour}} &&
        hours_on_same_day.any?{|hour| time_overlaps? time, hour, hour + duration}
    end

    def residue_for(time)
      interval_difference(time, beginning.to_time).modulo(@interval)
    end
  end
end
