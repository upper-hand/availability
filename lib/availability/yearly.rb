require_relative 'abstract_availability'

module Availability
  class Yearly < AbstractAvailability
    extend Createable

    def date_move_method
      :years
    end

    def residue_for(time)
      date = time.to_date
      (date.year - beginning.year).modulo(@interval)
    end
  end
end
