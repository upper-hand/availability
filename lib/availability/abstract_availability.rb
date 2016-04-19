module Availability
  class AbstractAvailability
    private_class_method :new # :nodoc:
  
    attr_accessor :interval, :start_time, :frequency, :duration, :stops_after
    attr_reader :residue

    #
    # Required arguments:
    #   interval: an integer that is the interval of occurrences per frequency
    #   start_time: a Time, Date, or DateTime that indicates when the event begins
    #   duration: an integer indicating how long the event lasts in seconds
    #
    # Optional arguements:
    #   frequency: a symbol, one of [:once, :daily, :monthly, :yearly]; defaults to :daily
    #   stops_after: number of occurrences after which the event ends
    #
    def initialize(frequency: :daily, stops_after: nil, interval: , start_time: , duration: )
      @frequency = frequency
      @interval = interval
      @start_time = start_time.to_time
      @duration = duration
      @stops_after = stops_after
      compute_residue
    end

    def beginning
      self.class.beginning
    end

    def end_time
      start_time + duration
    end

    def interval=(interval)
      @interval = interval
      compute_residue
    end

    def start_time=(start_time)
      @start_time = start_time
      compute_residue
    end

    def corresponds_to?(event)
      return unless occurs_at?(event.start_time) && occurs_at?(event.start_time + event.duration)
      if !!stops_after
        that_last = event.last_occurrence
        !that_last.nil? && occurs_at?(that_last) && that_last <= self.last_occurrence
      else
        true
      end
    end

    def occurs_at?(time)
      residue_for(time) == @residue && time_overlaps(time)
    end

    def last_occurrence
      return nil unless stops_after
      return start_time if @frequency == :once
      next_date = start_time +
        residue.modulo(@interval).send(date_move_method) +
        stops_after.send(date_move_method)
      next_occurrence next_date
    end

    def next_occurrence(from_date)
      residue = @residue - residue_for(from_date)
      next_date = from_date + residue.modulo(@interval).send(date_move_method)
      Time.new(next_date.year, next_date.month, next_date.day,
        start_time.hour, start_time.min, start_time.sec)
    end

    #
    # Returns an array of occurrences for n <= 1000, otherwise it returns a lazy enumerator
    #
    # n: Fixnum, how many occurrences to get
    # from_date: a Date, Time, or DateTime from which to start calculating
    #
    def next_n_occurrences(n, from_date)
      first_next_occurrence = next_occurrence(from_date)
      blk = proc { |i| first_next_occurrence + (@interval * i).send(date_move_method) }
      range = 0.upto(n - 1)
      range = range.lazy if n > 1000
      range.map &blk
    end

    def residue_for(time)
      raise 'subclass responsibility'
    end

    def date_move_method
      raise 'subclass responsibility'
    end

    private

    def compute_residue
      @residue = residue_for(@start_time)
    end

    def time_overlaps(time)
      that_start = time.seconds_since_midnight.to_i
      this_start = start_time.seconds_since_midnight.to_i
      this_end   = (start_time + duration).seconds_since_midnight.to_i
      (this_start..this_end).include?(that_start)
    end

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
