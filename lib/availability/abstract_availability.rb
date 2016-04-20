module Availability
  class AbstractAvailability
    include TimeOverlapping
    private_class_method :new # :nodoc:
  
    attr_accessor :frequency, :duration, :stops_by
    attr_reader :residue, :exclusions, :interval, :start_time

    #
    # Required arguments:
    #   interval: an integer that is the interval of occurrences per frequency
    #   start_time: a Time, Date, or DateTime that indicates when the availability begins
    #   duration: an integer indicating how long the availability lasts in seconds
    #
    # Optional arguements:
    #   frequency: a symbol, one of [:once, :daily, :monthly, :yearly]; defaults to :daily
    #   stops_by: specific date by which the availability ends
    #
    def initialize(frequency: :daily, stops_by: nil, exclusions: nil, interval: , start_time: , duration: )
      @frequency = frequency
      @interval = interval
      @start_time = start_time.to_time
      @duration = duration
      @stops_by = stops_by
      self.exclusions = exclusions
      compute_residue
    end

    def beginning
      self.class.beginning
    end

    def corresponds_to?(availability)
      return unless occurs_at?(availability.start_time) && occurs_at?(availability.start_time + availability.duration)
      if !!stops_by
        that_last = availability.last_occurrence
        !that_last.nil? && occurs_at?(that_last) && that_last <= self.last_occurrence
      else
        true
      end
    end

    def date_move_method
      raise 'subclass responsibility'
    end

    def end_time
      start_time + duration
    end

    def exclusions=(exclusions)
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

    def interval
      @interval
    end

    def interval=(interval)
      @interval = interval
      compute_residue
      self
    end

    def interval_difference(first, second)
      raise 'subclass responsibility'
    end

    def last_occurrence
      return nil unless stops_by
      unless @last_occurrence
        next_date = move_by start_time, interval_difference(start_time, stops_by)
        next_date = move_by next_date, -1 * interval while next_date >= stops_by && residue_for(next_date) != residue
        @last_occurrence = next_occurrence next_date
      end
      @last_occurrence
    end

    def move_by(time, amount)
      raise 'subclass responsibility'
    end

    def next_occurrence(from_date)
      residue = @residue - residue_for(from_date)
      date = move_by from_date, residue.modulo(interval)
      time = Time.new(date.year, date.month, date.day, start_time.hour, start_time.min, start_time.sec)
      if exclusions.any? {|rule| rule.violated_by? time}
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
    # Returns an array of occurrences for n <= 1000, otherwise it returns a lazy enumerator
    #
    # n: Fixnum, how many occurrences to get
    # from_date: a Date, Time, or DateTime from which to start calculating
    #
    def next_n_occurrences(n, from_date)
      first_next_occurrence = next_occurrence(from_date)
      blk = proc { |i| move_by first_next_occurrence, interval * i }
      range = 0.upto(n - 1)
      range = range.lazy if n > 1000
      range.map &blk
    end

    def occurs_at?(time)
      residue_for(time) == @residue && time_overlaps?(time, start_time, start_time + duration)
    end

    def residue_for(time)
      raise 'subclass responsibility'
    end

    def start_time=(start_time)
      @start_time = start_time
      compute_residue
      self
    end

    private

    def compute_residue
      @residue = residue_for(@start_time)
    end
  end
end
