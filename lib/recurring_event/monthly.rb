require_relative 'abstract_event'

module RecurringEvent
  class Monthly < AbstractEvent
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
