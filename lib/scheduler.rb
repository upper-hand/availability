require_relative 'recurring_event'

class Scheduler
  def initialize(availabilities)
    @availabilities = availabilities
  end

  def allow?(event)
    @availabilities.any? do |_event|
      _event.corresponds_to? event
    end
  end
end
