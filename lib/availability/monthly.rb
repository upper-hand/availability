require_relative 'abstract_availability'

module Availability
  class Monthly < AbstractAvailability
    extend Createable

    def date_move_method
      :months
    end

    def residue_for(time)
      date = time.to_date
      ((date.year - beginning.year) * 12 + (date.month - beginning.month)).modulo(@interval)
    end
  end
end
