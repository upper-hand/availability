module SchedulerSpecHelpers
  def one_hour_slot_per_week(at: , **rest)
    RecurringEvent.weekly **rest.merge(duration: 1.hour, start_time: Time.new(*at))
  end
end

RSpec.describe Scheduler do
  include SchedulerSpecHelpers

  context '#allow?' do
    let(:bob_availability) do
      [
        one_hour_slot_per_week(at: [2016, 4, 11, 9], stops_after: 4),
        one_hour_slot_per_week(at: [2016, 4, 12, 9], stops_after: 4),
        one_hour_slot_per_week(at: [2016, 4, 13, 9], stops_after: 4),
        one_hour_slot_per_week(at: [2016, 4, 14, 9], stops_after: 4),
        one_hour_slot_per_week(at: [2016, 4, 15, 9], stops_after: 4)
      ]
    end

    let(:bobs_schedule) { Scheduler.new bob_availability }

    it 'should allow an event request in the first week' do
      bob_availability.each do |a|
        expect(bobs_schedule.allow? a).to eq(true), "at #{a.start_time}"
      end
    end

    it 'should allow an event request in the second week' do
      expect(bobs_schedule.allow? one_hour_slot_per_week(at: [2016, 4, 18, 9], stops_after: 3)).to eq true
    end

    it 'should not allow an event request that is beyond the availability frequency' do
      expect(bobs_schedule.allow? one_hour_slot_per_week(at: [2016, 4, 18, 9], frequency: 4)).to eq false
    end
  end
end
