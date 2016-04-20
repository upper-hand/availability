require_relative 'abstract_availability'

module Availability
  class Monthly < AbstractAvailability
    extend Createable

    def date_move_method
      :months
    end

    def interval_difference(first, second)
      first_date, second_date = [first.to_date, second.to_date].sort
      (second_date.year - first_date.year) * 12 + (second_date.month - first_date.month)
    end

    def move_by(time, amount)
      time + amount.months
    end

    def residue_for(time)
      # date = time.to_date
      # ((date.year - beginning.year) * 12 + (date.month - beginning.month)).modulo(@interval)
      interval_difference(beginning, time).modulo(@interval)
    end
  end
end
