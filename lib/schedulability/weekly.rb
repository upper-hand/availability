require_relative 'availability'

module Schedulability
  class Weekly < Availability
    extend Createable

    def interval
      @interval * 7
    end

    def interval_difference(first, second)
      first_date, second_date = [first.to_date, second.to_date].sort
      (second_date - first_date).to_i
    end

    def move_by(time, amount)
      time + amount.days
    end

    def residue_for(time)
      interval_difference(time, beginning).modulo(interval)
    end
  end
end
