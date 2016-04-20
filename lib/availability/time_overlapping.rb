module Availability
  module TimeOverlapping
    def time_overlaps?(time, start_time, end_time)
      that_start = time.seconds_since_midnight.to_i
      this_start = start_time.seconds_since_midnight.to_i
      this_end   = end_time.seconds_since_midnight.to_i
      (this_start..this_end).include?(that_start)
    end

    private
    def hour_offset_from_midnight(time)
      time.to_time.hour * 60 * 60
    end

    def minute_offset_from_midnight(time)
      time.to_time.min * 60
    end

    def second_offset_from_midnight(time)
      time.to_time.sec
    end
  end
end
