module Availability
  # @abstract see concrete classes: Once, Daily, Weekly, Monthly and Yearly
  class AbstractAvailability
    private_class_method :new # :nodoc:
  
    attr_accessor :capacity, :duration, :stops_by
    attr_reader :exclusions, :interval, :residue, :start_time

    #
    # Required arguments:
    # @param [Fixnum] interval an integer that is the interval of occurrences per frequency
    # @param [Time] start_time a Time, Date, or DateTime that indicates when the availability begins
    # @param [Fixnum] duration an integer indicating how long the availability lasts in seconds
    #
    # Optional arguements:
    # @param [Time] stops_by specific Date, Time, or DateTime by which the availability ends
    #
    def initialize(capacity: Float::INFINITY, exclusions: nil, stops_by: nil, duration: , interval: , start_time: )
      raise ArgumentError, "start_time is required" if start_time.nil?
      raise ArgumentError, "duration is required" if duration.nil?
      raise ArgumentError, "interval is required" if interval.nil?
      @capacity = capacity
      @duration = duration
      @interval = interval
      @start_time = start_time.to_time
      @stops_by = stops_by
      self.exclusions = exclusions
      compute_residue
    end

    #
    # The copy constructor that Ruby calls when cloning or duping an object.
    #
    def initialize_copy(orig)
      super
      @exclusions = orig.exclusions
      compute_residue
    end

    def beginning
      self.class.beginning
    end

    # @!group Testing

    #
    # Whether or not the availability is covered by the receiver
    #
    # @param [Availability::AbstractAvailability] availability the availability to test for coverage
    #
    # @return [Boolean] true or false
    #
    def corresponds_to?(availability)
      return false unless occurs_at?(availability.start_time) \
        && occurs_at?(availability.start_time + availability.duration - 1.second)
      if !!stops_by
        that_last = availability.last_occurrence
        !that_last.nil? \
          && occurs_at?(that_last) \
          && occurs_at?(that_last + availability.duration - 1.second) \
          && that_last.to_date <= self.last_occurrence.to_date
      else
        true
      end
    end

    #
    # Whether or not the given time is covered by the receiver
    #
    # @param [Time] time the Time to test for coverage
    #
    # @return [Boolean] true or false
    #
    def occurs_at?(time)
      next_occurrence = next_occurrence(time) || last_occurrence
      residue_for(time) == @residue \
        && !next_occurrence.nil? \
        && time_overlaps?(time, next_occurrence, next_occurrence + duration)
    end

    # @!endgroup

    # @!group Occurrences

    #
    # Calculates the last occurrence of an availability
    #
    # @return [Time] the last occurrence of the receiver, or nil if stops_by is not set
    #
    def last_occurrence
      return nil unless stops_by
      unless @last_occurrence
        next_date = move_by start_time, interval_difference(start_time, stops_by)
        next_date = move_by next_date, -1 * interval while next_date >= stops_by && residue_for(next_date) != residue
        @last_occurrence = next_occurrence next_date
      end
      @last_occurrence
    end

    #
    # Calculates a time for the next occurrence on or after the given date or time.
    # If no occurrence exists, `nil` is returned.
    #
    # from_date: a Date, Time, or DateTime from which to start calculating
    #
    # @return [Time] the next occurrence (or nil)
    #
    def next_occurrence(from_date)
      residue = @residue - residue_for(from_date)
      date = move_by from_date, residue.modulo(interval)
      time = Time.new(date.year, date.month, date.day, start_time.hour, start_time.min, start_time.sec)
      if (exx = exclusions.detect {|rule| rule.violated_by? time})
        if stops_by && time > stops_by
          nil
        else
          next_occurrence(move_by time, 1)
        end
      else
        time
      end
    end

    #
    # Calculates occurrences for n <= 1000; where n > 1000, it returns a lazy enumerator
    #
    # @param [Fixnum] n how many occurrences to get
    # @param [Date, Time, DateTime] from_date time from which to start calculating
    #
    # @return [Enumerable] an array of [Time] or lazy enumeration for n > 1000
    #
    def next_n_occurrences(n, from_date)
      first_next_occurrence = next_occurrence(from_date)
      blk = proc { |i| move_by first_next_occurrence, interval * i }
      range = 0.upto(n - 1)
      range = range.lazy if n > 1000
      range.map &blk
    end

    # @!endgroup

    # @!group Accessors

    def end_time
      start_time + duration
    end

    def exclusions=(exclusions)
      #TODO: should be a set of exclusions
      @exclusions = Array(exclusions).flatten.compact + [
        Exclusion.before_day(start_time),
        Exclusion.before_time(start_time)
      ]
      if stops_by
        @exclusions += [
          Exclusion.after_day(stops_by),
          Exclusion.after_time(stops_by)
          # TODO: should previous be: Exclusion.after_time(start_time + duration)
        ]
      end
      self
    end

    def interval=(interval)
      @interval = interval
      compute_residue
      self
    end

    def start_time=(start_time)
      @start_time = start_time
      compute_residue
      self
    end

    # @!endgroup

    # @!group Helpers

    def time_overlaps?(time, start_time, end_time)
      that_start = time.to_i
      this_start = start_time.to_i
      this_end   = end_time.to_i
      (this_start...this_end).include?(that_start)
    end

    # @!endgroup

    # @!group Subclass Responsibilities

    def interval_difference(first, second)
      raise 'subclass responsibility'
    end

    def move_by(time, amount)
      raise 'subclass responsibility'
    end

    def residue_for(time)
      raise 'subclass responsibility'
    end

    # @!endgroup

    private

    def compute_residue
      @residue = residue_for(@start_time)
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
