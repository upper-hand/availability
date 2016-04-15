require_relative 'abstract_event'

module RecurringEvent
  class Weekly < AbstractEvent
    extend Createable

    def date_move_method
      :weeks
    end

    def residue_for(time)
      date = time.to_date
      ((date.cweek - beginning.cweek) * 52).modulo(@interval)
    end
  end
end
