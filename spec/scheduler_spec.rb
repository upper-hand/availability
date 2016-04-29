module SchedulerSpecHelpers
  def T(*args)
    Time.new *args
  end

  def one_hour_slot_per_week(**args)
    Availability.weekly **args, duration: 1.hour
  end

  def half_hour_slot_per_week(**args)
    Availability.weekly **args, duration: 30.minutes
  end
end

RSpec.describe Scheduler do
  include SchedulerSpecHelpers

  context '#allow?' do
    let(:bob_availabilities) do
      [
        one_hour_slot_per_week(start_time: T(2016, 4, 11, 9), stops_by: T(2016, 5,  9, 9)),
        one_hour_slot_per_week(start_time: T(2016, 4, 12, 9), stops_by: T(2016, 5, 10, 9)),
        one_hour_slot_per_week(start_time: T(2016, 4, 13, 9), stops_by: T(2016, 5, 11, 9)),
        one_hour_slot_per_week(start_time: T(2016, 4, 14, 9), stops_by: T(2016, 5, 12, 9)),
        one_hour_slot_per_week(start_time: T(2016, 4, 15, 9), stops_by: T(2016, 5, 13, 9))
      ]
    end

    let(:bobs_schedule) { Scheduler.new bob_availabilities }

    describe '#schedule' do
      let(:request) { bob_availabilities.first.dup }

      it 'accepts a request' do
        expect{ bobs_schedule.schedule availability_request: request }.to \
          change{ bobs_schedule.scheduled.size }.from(0).to(1)
      end

      it 'does not accept a request if capacity is already met' do
        bob_availabilities.first.capacity = 0
        expect{ bobs_schedule.schedule availability_request: request }.not_to \
          change{ bobs_schedule.scheduled.size }
      end

      context 'with a shorter slot that fits within the availability' do
        let(:request) do
          half_hour_slot_per_week start_time: T(2016, 4, 14, 9, 15), stops_by: T(2016, 5, 12, 9, 45)
        end

        it 'accepts a request' do
          expect{ bobs_schedule.schedule availability_request: request }.to \
            change{ bobs_schedule.scheduled.size }.from(0).to(1)
        end

        it 'does not accept a request if capacity is already met' do
          bob_availabilities.first.capacity = 0
          expect{ bobs_schedule.schedule availability_request: request }.not_to \
            change{ bobs_schedule.scheduled.size }
        end
      end
    end

    describe '#allow?' do
      context 'enforces parameter values' do
        it { expect{bobs_schedule.allow?}.to raise_error ArgumentError }
        it { expect{bobs_schedule.allow? availability_request: nil}.to raise_error ArgumentError }
        it { expect{bobs_schedule.allow? start_time: nil }.to raise_error ArgumentError }
        it { expect{bobs_schedule.allow? start_time: Date.today }.to raise_error ArgumentError }
        it { expect{bobs_schedule.allow? end_time: nil }.to raise_error ArgumentError }
        it { expect{bobs_schedule.allow? end_time: Date.today }.to raise_error ArgumentError }
        it { expect{bobs_schedule.allow? availability_request: one_hour_slot_per_week(start_time: T(0))}.not_to raise_error }
        it { expect{bobs_schedule.allow? start_time: Date.today, end_time: Date.tomorrow}.not_to raise_error }
      end

      context 'with Availability objects' do
        it 'allows an event requests that start in the first week and go through the end of the availability' do
          bob_availabilities.each do |a|
            expect(bobs_schedule.allow? availability_request: a).to be_truthy, "at #{a.start_time}"
          end
        end

        it 'allows an event request in the second week that lasts until the end of the availability' do
          ar = one_hour_slot_per_week(start_time: T(2016, 4, 18, 9), stops_by: T(2016, 5, 2, 9))
          expect(bobs_schedule.allow? availability_request: ar).to be_truthy
        end

        it 'does not allow an event request that is beyond the availability frequency' do
          expect(bobs_schedule.allow? availability_request: one_hour_slot_per_week(start_time: T(2016, 4, 18, 9), frequency: 4)).to be_falsey
        end

        it 'does not allow an event request that starts before the availability frequency' do
          expect(bobs_schedule.allow? availability_request: one_hour_slot_per_week(start_time: T(2016, 4, 4, 9), frequency: 4)).to be_falsey
        end

        it 'does not allow an event request with a different frequency' do
          expect(bobs_schedule.allow? availability_request: one_hour_slot_per_week(start_time: T(2016, 4, 4, 9), frequency: 5)).to be_falsey
        end
      end

      context 'with start/end times' do
        it 'allows an event requests that start in the first week and go through the end of the availability' do
          bob_availabilities.each do |a|
            expect(bobs_schedule.allow? start_time: a.start_time, end_time: a.end_time).to be_truthy, "at #{a.start_time}"
          end
        end

        it 'allows an event request in the second week that lasts until the end of the availability' do
          a = bob_availabilities[1]
          expect(bobs_schedule.allow? start_time: a.start_time, end_time: a.end_time).to be_truthy
        end

        it 'does not allow an event request that is beyond the availability' do
          start_time = bob_availabilities.last.start_time + 1.day
          end_time = bob_availabilities.last.start_time + 2.days - 1.hour
          expect(bobs_schedule.allow? start_time: start_time, end_time: end_time).to be_falsey
        end

        it 'does not allow an event request that starts before the availability frequency' do
          start_time = bob_availabilities.first.start_time - 1.hour
          end_time = bob_availabilities.first.start_time
          expect(bobs_schedule.allow? start_time: start_time, end_time: end_time).to be_falsey
        end
      end
    end
  end
end
