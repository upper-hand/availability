require 'rubygems'
require 'date'
require 'bundler/setup'
require 'active_support'
require 'active_support/core_ext'

# shamelessly adapted from the following article
# http://dmcca.be/2014/01/09/recurring-subscriptions-with-ruby-rspec-and-modular-arithmetic.html
class RecurringEvent
  cattr_reader :beginning
  attr_accessor :interval, :start_time, :frequency, :duration, :stops_after
  attr_reader :residue

  @@beginning = Date.new(1970, 1, 1)

  module FactoryMethods
    %w{day week month year}.each do |keyword|
      frequency = keyword == 'day' ? :daily : :"#{keyword}ly"
      
      define_method "every_#{keyword}" do |**args|
        options = {}.merge(args).merge(frequency: frequency, interval: 1)
        new **options
      end

      define_method "every_other_#{keyword}" do |**args|
        options = {}.merge(args).merge(frequency: frequency, interval: 2)
        new **options
      end

      define_method "every_three_#{keyword}" do |**args|
        options = {}.merge(args).merge(frequency: frequency, interval: 3)
        new **options
      end

      define_method "every_four_#{keyword}" do |**args|
        options = {}.merge(args).merge(frequency: frequency, interval: 3)
        new **options
      end
    end

    alias_method :daily, :every_day
    alias_method :weekly, :every_week
    alias_method :monthly, :every_month
    alias_method :yearly, :every_year
  end
  extend FactoryMethods

  #
  # Required arguments:
  #   interval: an integer that is the interval of occurrences per frequency
  #   start_time: a Time, Date, or DateTime that indicates when the event begins
  #   duration: an integer indicating how long the event lasts in seconds
  #
  # Optional arguements:
  #   frequency: a symbol, one of [:daily, :monthly, :yearly]; defaults to :daily
  #   stops_after: number of occurrences after which the event ends
  #
  def initialize(frequency: :daily, interval: , start_time: , duration: , stops_after: nil)
    @frequency = frequency
    @interval = interval
    @start_time = start_time.to_time
    @duration = duration
    @stops_after = stops_after
    compute_residue
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

  def next_n_occurrences(n, from_date)
    first_next_occurrence = next_occurrence(from_date)
    0.upto(n - 1).map { |i| first_next_occurrence + (@interval * i).send(date_move_method) }
  end

  private

  def residue_for(time)
    date = time.to_date
    case @frequency
    when :daily
      (date - @@beginning).to_i.modulo(@interval)
    when :weekly
      ((date.cweek - @@beginning.cweek) * 52).modulo(@interval)
    when :monthly
      ((date.year - @@beginning.year) * 12 + (date.month - @@beginning.month)).modulo(@interval)
    when :yearly
      (date.year - @@beginning.year).modulo(@interval)
    end
  end

  def compute_residue
    @residue = residue_for(@start_time)
  end

  def date_move_method
    @date_move_method ||= case @frequency
    when :daily
      :days
    when :weekly
      :weeks
    when :monthly
      :months
    when :yearly
      :years
    end
  end

  def time_overlaps(time)
    # that_start = hour_offset_from_midnight(time) + minute_offset_from_midnight(time) + second_offset_from_midnight(time)
    # this_start = hour_offset_from_midnight(start_time) + minute_offset_from_midnight(start_time) + second_offset_from_midnight(start_time)
    # this_end   = hour_offset_from_midnight(start_time + duration) +
    #              minute_offset_from_midnight(start_time + duration) +
    #              second_offset_from_midnight(start_time + duration)

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
