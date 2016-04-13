require 'rubygems'
require 'date'
require 'bundler/setup'
require 'active_support'
require 'active_support/core_ext'

# shamelessly adapted from the following article
# http://dmcca.be/2014/01/09/recurring-subscriptions-with-ruby-rspec-and-modular-arithmetic.html
class RecurringEvent
  cattr_reader :beginning
  attr_accessor :interval, :start_time, :frequency, :duration_per_day
  attr_reader :residue

  @@beginning = Date.new(1970, 1, 1)
  @@beginning_time = 0
  @@seconds_per_day = 86400

  def initialize(frequency: :daily, interval: , start_time: , duration_per_day: )
    @frequency = frequency
    @interval = interval
    @start_time = start_time.to_time
    @duration_per_day = duration_per_day
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

  def occurs_at?(time)
    residue_for(time) == @residue && time_overlaps(time)
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
    when :monthly
      :months
    when :yearly
      :years
    end
  end

  def time_overlaps(time)
    that_start = hour_offset_from_midnight(time) + minute_offset_from_midnight(time) + second_offset_from_midnight(time)
    this_start = hour_offset_from_midnight(start_time) + minute_offset_from_midnight(start_time) + second_offset_from_midnight(start_time)
    this_end   = hour_offset_from_midnight(start_time + duration_per_day) +
                 minute_offset_from_midnight(start_time + duration_per_day) +
                 second_offset_from_midnight(start_time + duration_per_day)

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
