require_relative 'availability'

module Schedulability
  class Yearly < Availability
    extend Createable

    def interval_difference(first, second)
      first_date, second_date = [first.to_date, second.to_date].sort
      second_date.year - first_date.year
    end

    def move_by(time, amount)
      time + amount.years
    end

    def residue_for(time)
      # date = time.to_date
      # (date.year - beginning.year).modulo(@interval)
      interval_difference(beginning, time).modulo(@interval)
    end
  end
end
