require_relative 'availability'

class Scheduler
  attr_reader :availabilities, :scheduled

  #
  # availabilities: a list of Availability instances defining when the resource is available
  #
  def initialize(availabilities)
    @availabilities = validate_availabilities availabilities
    @scheduled = Hash.new{|h, k| h[k] = []}
  end

  #
  # Adds the given request to the list of scheduled events.
  #
  # request: an Availability instance
  #
  def add_to_schedule(event)
    availability = availability_for(event)
    scheduled[availability] << event unless scheduled[availability].size >= availability.capacity
    self
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
  # Returns the first availability that corresponds to the availability request. If no
  # availability is found, returns nil.
  #
  def allow?(**args)
    availability_request = convert **args
    availability_for availability_request
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
  # returns boolean indicating whether the availability request was scheduled.
  #
  def schedule(**args)
    request = convert **args
    return self unless allow? availability_request: request
    request.schedule_on self
    self
  end

  private
  def availability_for(request)
    @availabilities.detect do |some_availability|
      some_availability.corresponds_to? request
    end
  end

  def convert(availability_request: nil, start_time: nil, end_time: nil)
    validate_allow_params! availability_request, start_time, end_time
    if availability_request.nil?
      availability_request = Availability::Once.create(
        start_time: start_time, duration: (end_time.to_time - start_time.to_time).to_i)
    else
      availability_request
    end
  end

  def validate_availabilities(availabilities)
    list = Array(availabilities).flatten.compact
    return list if list.all? { |e| e.respond_to? :corresponds_to? }
    raise ArgumentError, "expected a list of availabilities"
  end

  def validate_allow_params!(availability, start_time, end_time)
    return if Availability.availability?(availability)
    return if valid_time?(start_time) && valid_time?(end_time)
    raise ArgumentError, "must specify either availability_request or (start_time and end_time)"
  end

  def valid_time?(a_time)
    Time === a_time || DateTime === a_time || Date === a_time
  end
end
