require_relative 'abstract_availability'

module Availability
  class Daily < AbstractAvailability
    extend Createable

    def date_move_method
      :days
    end

    def residue_for(time)
      date = time.to_date
      (date - beginning).to_i.modulo(@interval)
    end
  end
end
