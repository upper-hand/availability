require_relative 'availability'

class Scheduler
  #
  # availabilities: a list of Availability instances defining when the resource is available
  #
  def initialize(availabilities, capacity: nil)
    @availabilities = validate_availabilities availabilities
    @capacity = capacity
  end

  #
  # This method expects either an availability request or a start/end time pair. If the
  # start/end time pair is offered, this method acts the same as if an Availability::Once
  # request was offered with the given start_time and a duration going through the given
  # end_time.
  #
  # availability_request: an Availability instance
  # start_time: Time/DateTime representative of a single request starting at that time
  # end_time: Time/DateTime representative of a single request ending at that time
  #
  # returns boolean indicating whether the availability request is allowed.
  #
  def allow?(availability_request: nil, start_time: nil, end_time: nil)
    validate_allow_params! availability_request, start_time, end_time
    if availability_request.nil?
      availability_request = Availability::Once.create(
        start_time: start_time, duration: (end_time.to_time - start_time.to_time).to_i)
    end
    @availabilities.any? do |some_availability|
      some_availability.corresponds_to? availability_request
    end
  end

  private
  def validate_availabilities(availabilities)
    list = Array(availabilities).flatten.compact
    return list if list.all?{|e| Availability::AbstractAvailability === e}
    raise ArgumentError, "expected a list of availabilities"
  end

  def validate_allow_params!(availability, start_time, end_time)
    return if Availability::AbstractAvailability === availability
    return if valid_time?(start_time) && valid_time?(end_time)
    raise ArgumentError, "must specify either availability_request or (start_time and end_time)"
  end

  def valid_time?(a_time)
    Time === a_time || DateTime === a_time || Date === a_time
  end
end
