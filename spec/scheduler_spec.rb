module SchedulerSpecHelpers
  def one_hour_slot_per_week(at: , **rest)
    Availability.weekly **rest.merge(duration: 1.hour, start_time: Time.new(*at))
  end
end

RSpec.describe Scheduler do
  include SchedulerSpecHelpers

  context '#allow?' do
    let(:bob_availabilities) do
      [
        one_hour_slot_per_week(at: [2016, 4, 11, 9], stops_after: 4),
        one_hour_slot_per_week(at: [2016, 4, 12, 9], stops_after: 4),
        one_hour_slot_per_week(at: [2016, 4, 13, 9], stops_after: 4),
        one_hour_slot_per_week(at: [2016, 4, 14, 9], stops_after: 4),
        one_hour_slot_per_week(at: [2016, 4, 15, 9], stops_after: 4)
      ]
    end

    let(:bobs_schedule) { Scheduler.new bob_availabilities }

    context '#allow? enforces parameter values' do
      it { expect{bobs_schedule.allow?}.to raise_error ArgumentError }
      it { expect{bobs_schedule.allow? availability_request: nil}.to raise_error ArgumentError }
      it { expect{bobs_schedule.allow? start_time: nil }.to raise_error ArgumentError }
      it { expect{bobs_schedule.allow? start_time: Date.today }.to raise_error ArgumentError }
      it { expect{bobs_schedule.allow? end_time: nil }.to raise_error ArgumentError }
      it { expect{bobs_schedule.allow? end_time: Date.today }.to raise_error ArgumentError }
      it { expect{bobs_schedule.allow? availability_request: one_hour_slot_per_week(at: 0)}.not_to raise_error }
      it { expect{bobs_schedule.allow? start_time: Date.today, end_time: Date.tomorrow}.not_to raise_error }
    end

    context '#allow? with Availability objects' do
      it 'allows an event requests that start in the first week and go through the end of the availability' do
        bob_availabilities.each do |a|
          expect(bobs_schedule.allow? availability_request: a).to eq(true), "at #{a.start_time}"
        end
      end

      it 'allows an event request in the second week that lasts until the end of the availability' do
        expect(bobs_schedule.allow? availability_request: one_hour_slot_per_week(at: [2016, 4, 18, 9], stops_after: 3)).to eq true
      end

      it 'does not allow an event request that is beyond the availability frequency' do
        expect(bobs_schedule.allow? availability_request: one_hour_slot_per_week(at: [2016, 4, 18, 9], frequency: 4)).to eq false
      end

      it 'does not allow an event request that starts before the availability frequency' do
        expect(bobs_schedule.allow? availability_request: one_hour_slot_per_week(at: [2016, 4, 4, 9], frequency: 4)).to eq false
      end

      it 'does not allow an event request with a different frequency' do
        expect(bobs_schedule.allow? availability_request: one_hour_slot_per_week(at: [2016, 4, 4, 9], frequency: 5)).to eq false
      end
    end

    context '#allow? with start/end times' do
      it 'allows an event requests that start in the first week and go through the end of the availability' do
        bob_availabilities.each do |a|
          expect(bobs_schedule.allow? start_time: a.start_time, end_time: a.end_time).to eq(true), "at #{a.start_time}"
        end
      end

      it 'allows an event request in the second week that lasts until the end of the availability' do
        a = bob_availabilities[1]
        expect(bobs_schedule.allow? start_time: a.start_time, end_time: a.end_time).to eq true
      end

      it 'does not allow an event request that is beyond the availability' do
        start_time = bob_availabilities.last.start_time + 1.day
        end_time = bob_availabilities.last.start_time + 2.days - 1.hour
        expect(bobs_schedule.allow? start_time: start_time, end_time: end_time).to eq false
      end

      it 'does not allow an event request that starts before the availability frequency' do
        start_time = bob_availabilities.first.start_time - 1.hour
        end_time = bob_availabilities.first.start_time
        expect(bobs_schedule.allow? start_time: start_time, end_time: end_time).to eq false
      end
    end

    context '#allow? checks capacity' do
      pending
    end
  end
end
