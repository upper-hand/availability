require_relative 'abstract_availability'

module Availability
  class Daily < AbstractAvailability
    extend Createable

    def interval_difference(this, that)
      first, second = [this.to_date, that.to_date].sort
      (second - first).to_i
    end

    def move_by(time, amount)
      time + amount.days
    end

    def residue_for(time)
      interval_difference(time, beginning).modulo(@interval)
    end
  end
end
