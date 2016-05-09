RSpec.describe Availability do
  include AvailabilitySpecHelpers

  subject { Availability.hourly(duration: 30.minutes, start_time: Date.tomorrow) }

  describe '#residue' do
    context 'when interval is 2 hours' do
      it 'computes members of the residue class 0' do
        availabilities = [
          Availability.hourly(duration: 90.minutes, interval: 2, start_time: beginning),
          Availability.hourly(duration: 90.minutes, interval: 2, start_time: beginning + 2.hours),
          Availability.hourly(duration: 90.minutes, interval: 2, start_time: beginning + 4.hours),
          Availability.hourly(duration: 90.minutes, interval: 2, start_time: beginning + 6.hours),
          Availability.hourly(duration: 90.minutes, interval: 2, start_time: beginning + 8.hours)
        ]

        expect(unique_residues(availabilities)).to eq([0])
      end

      context 'every 4 hours' do
        it 'computes members of the residue class 0' do
          availabilities = [
            Availability.hourly(duration: 90.minutes, interval: 4, start_time: beginning),
            Availability.hourly(duration: 90.minutes, interval: 4, start_time: beginning + 4.hours),
            Availability.hourly(duration: 90.minutes, interval: 4, start_time: beginning + 8.hours)
          ]

          expect(unique_residues(availabilities)).to eq([0])
        end

        it 'computes members of the residue class 1' do
          availabilities = [
            Availability.hourly(duration: 90.minutes, interval: 4, start_time: beginning + 1.hour),
            Availability.hourly(duration: 90.minutes, interval: 4, start_time: beginning + 5.hours),
            Availability.hourly(duration: 90.minutes, interval: 4, start_time: beginning + 9.hours)
          ]

          expect(unique_residues(availabilities)).to eq([1])
        end

        it 'computes members of the residue class 2' do
          availabilities = [
            Availability.hourly(duration: 90.minutes, interval: 4, start_time: beginning + 2.hour),
            Availability.hourly(duration: 90.minutes, interval: 4, start_time: beginning + 6.hours),
            Availability.hourly(duration: 90.minutes, interval: 4, start_time: beginning + 10.hours)
          ]

          expect(unique_residues(availabilities)).to eq([2])
        end

        it 'computes members of the residue class 3' do
          availabilities = [
            Availability.hourly(duration: 90.minutes, interval: 4, start_time: beginning + 3.hour),
            Availability.hourly(duration: 90.minutes, interval: 4, start_time: beginning + 7.hours),
            Availability.hourly(duration: 90.minutes, interval: 4, start_time: beginning + 11.hours)
          ]

          expect(unique_residues(availabilities)).to eq([3])
        end
      end

      it 'computes the complete residue system' do
        availabilities = [
          Availability.hourly(duration: 90.minutes, interval: 12, start_time: beginning),
          Availability.hourly(duration: 90.minutes, interval: 12, start_time: beginning + 1.hour),
          Availability.hourly(duration: 90.minutes, interval: 12, start_time: beginning + 2.hours),
          Availability.hourly(duration: 90.minutes, interval: 12, start_time: beginning + 3.hours),
          Availability.hourly(duration: 90.minutes, interval: 12, start_time: beginning + 4.hours),
          Availability.hourly(duration: 90.minutes, interval: 12, start_time: beginning + 5.hours),
          Availability.hourly(duration: 90.minutes, interval: 12, start_time: beginning + 6.hours),
          Availability.hourly(duration: 90.minutes, interval: 12, start_time: beginning + 7.hours),
          Availability.hourly(duration: 90.minutes, interval: 12, start_time: beginning + 8.hours),
          Availability.hourly(duration: 90.minutes, interval: 12, start_time: beginning + 9.hours),
          Availability.hourly(duration: 90.minutes, interval: 12, start_time: beginning + 10.hours),
          Availability.hourly(duration: 90.minutes, interval: 12, start_time: beginning + 11.hours),
          Availability.hourly(duration: 90.minutes, interval: 12, start_time: beginning + 12.hours)
        ]

        expect(residues(availabilities)).to eq([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0])
      end
    end
  end

  describe '#occurs_at?' do
    let(:availabilities) {[
      Availability.hourly(duration: 90.minutes, interval: 2, start_time: beginning),
      Availability.hourly(duration: 90.minutes, interval: 2, start_time: beginning + 2.hours),
      Availability.hourly(duration: 90.minutes, interval: 2, start_time: beginning + 4.hours),
      Availability.hourly(duration: 90.minutes, interval: 2, start_time: beginning + 6.hours),
      Availability.hourly(duration: 90.minutes, interval: 2, start_time: beginning + 8.hours)
    ]}

    context 'when time is offset from the slot time' do
      context 'but would finish on time' do
        it 'occurs' do
          (1..15).each do |offset|
            expect(availabilities.first.occurs_at?(beginning + offset.minutes)).to be_truthy
          end
        end
      end

      context 'and would not finish on time' do
        it 'occurs' do
          expect(availabilities.first.occurs_at?(beginning + 16.minutes)).to be_truthy
        end
      end
    end
  end
end
