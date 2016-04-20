require_relative 'abstract_availability'

module Availability
  class Weekly < AbstractAvailability
    extend Createable

    def date_move_method
      :days
    end

    def interval
      @interval * 7
    end

    def interval_difference(first, second)
      first_date, second_date = [first.to_date, second.to_date].sort
      (second_date - first_date).to_i #/ interval
    end

    def move_by(time, amount)
      time + amount.days
    end

    def residue_for(time)
      (time.to_date - beginning.to_date).to_i.modulo(interval)
    end
  end
end
