require_relative 'abstract_event'

module RecurringEvent
  class Once < AbstractEvent
    extend Createable

    def self.default_args
      {frequency: :once, interval: 0, stops_after: 1}
    end

    def date_move_method
      nil
    end

    def residue_for(time)
      0
    end
  end
end
