require_relative 'abstract_event'

module RecurringEvent
  class Yearly < AbstractEvent
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
