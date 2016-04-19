module AvailabilitySpecHelpers
  def residues(recurring_events)
    recurring_events.map(&:residue)
  end

  def unique_residues(recurring_events)
    recurring_events.map(&:residue).uniq
  end

  def beginning
    Availability.beginning.to_time
  end
end

RSpec.describe Availability do
  include AvailabilitySpecHelpers

  describe '#initialize' do
    context 'daily frequency' do
      subject { Availability.once(duration: 15.minutes, start_time: Date.tomorrow) }

      its(:interval) { should eq(0) }
      its(:start_time) { should eq(Date.tomorrow.to_time) }
      its(:frequency) { should eq(:once) }
      its(:duration) { should eq(15.minutes) }
    end

    context 'daily frequency' do
      subject { Availability.create(duration: 15.minutes, interval: 4, start_time: Date.tomorrow) }

      its(:interval) { should eq(4) }
      its(:start_time) { should eq(Date.tomorrow.to_time) }
      its(:frequency) { should eq(:daily) }
      its(:duration) { should eq(15.minutes) }
    end

    context 'weekly frequency' do
      subject { Availability.weekly(duration: 15.minutes, interval: 3, start_time: Date.tomorrow) }

      its(:interval) { should eq(3) }
      its(:start_time) { should eq(Date.tomorrow.to_time) }
      its(:frequency) { should eq(:weekly) }
      its(:duration) { should eq(15.minutes) }
    end

    context 'monthly frequency' do
      subject { Availability.monthly(duration: 2.hours, interval: 5, start_time: Date.tomorrow) }

      its(:interval) { should eq(5) }
      its(:start_time) { should eq(Date.tomorrow.to_time) }
      its(:frequency) { should eq(:monthly) }
      its(:duration) { should eq(2.hours) }
    end

    context 'yearly frequency' do
      subject { Availability.yearly(duration: 30.minutes, interval: 2, start_time: Date.tomorrow) }

      its(:interval) { should eq(2) }
      its(:start_time) { should eq(Date.tomorrow.to_time) }
      its(:frequency) { should eq(:yearly) }
      its(:duration) { should eq(30.minutes) }
    end

    context 'every two|three|four|five factories' do
      {days: :daily, weeks: :weekly, months: :monthly, years: :yearly}.each do | factory_suffix, frequency |
        {two: 2, three: 3, four: 4, five: 5}.each do | name, interval |
          it "#every_#{name}_#{factory_suffix}" do
            event = Availability.send("every_#{name}_#{factory_suffix}", duration: 1.hour, start_time: Date.today)
            expect(event.interval).to eq interval
            expect(event.frequency).to eq frequency
            expect(event.duration).to eq 1.hour
          end
        end
      end
    end

    context 'every_other_* factories' do
      {day: :daily, week: :weekly, month: :monthly, year: :yearly}.each do | factory_suffix, frequency |
        it "#every_other_#{factory_suffix}" do
          event = Availability.send("every_other_#{factory_suffix}", duration: 1.hour, start_time: Date.today)
          expect(event.interval).to eq 2
          expect(event.frequency).to eq frequency
          expect(event.duration).to eq 1.hour
        end
      end
    end
  end

  describe '#residue' do
    context 'when the frequency is daily' do
      context 'when interval is weekly' do
        it 'computes members of the residue class 0' do
          events = [
            Availability.create(duration: 45.minutes, interval: 7, start_time: beginning),
            Availability.create(duration: 45.minutes, interval: 7, start_time: beginning + 7.days),
            Availability.create(duration: 45.minutes, interval: 7, start_time: beginning + 70.days)
          ]

          expect(unique_residues(events)).to eq([0])
        end

        it 'computes members of the residue class 1' do
          events = [
            Availability.create(duration: 45.minutes, interval: 7, start_time: beginning + 1.day),
            Availability.create(duration: 45.minutes, interval: 7, start_time: beginning + 8.days),
            Availability.create(duration: 45.minutes, interval: 7, start_time: beginning + 71.days)
          ]

          expect(unique_residues(events)).to eq([1])
        end

        it 'computes the complete residue system' do
          events = [
            Availability.create(duration: 45.minutes, interval: 7, start_time: beginning),
            Availability.create(duration: 45.minutes, interval: 7, start_time: beginning + 1.day),
            Availability.create(duration: 45.minutes, interval: 7, start_time: beginning + 2.days),
            Availability.create(duration: 45.minutes, interval: 7, start_time: beginning + 3.days),
            Availability.create(duration: 45.minutes, interval: 7, start_time: beginning + 4.days),
            Availability.create(duration: 45.minutes, interval: 7, start_time: beginning + 5.days),
            Availability.create(duration: 45.minutes, interval: 7, start_time: beginning + 6.days),
            Availability.create(duration: 45.minutes, interval: 7, start_time: beginning + 7.days)
          ]

          expect(residues(events)).to eq([0, 1, 2, 3, 4, 5, 6, 0])
        end
      end

      context 'when interval is every 100 days' do
        it 'computes members of the residue class 0' do
          events = [
            Availability.create(duration: 45.minutes, interval: 100, start_time: beginning),
            Availability.create(duration: 45.minutes, interval: 100, start_time: beginning + 100.days),
            Availability.create(duration: 45.minutes, interval: 100, start_time: beginning + 500.days)
          ]

          expect(unique_residues(events)).to eq([0])
        end

        it 'computes members of the residue class 25' do
          events = [
            Availability.create(duration: 45.minutes, interval: 100, start_time: beginning + 25.day),
            Availability.create(duration: 45.minutes, interval: 100, start_time: beginning + 125.days),
            Availability.create(duration: 45.minutes, interval: 100, start_time: beginning + 525.days)
          ]

          expect(unique_residues(events)).to eq([25])
        end
      end
    end

    context 'when the frequency is monthly' do
      context 'when interval is every 5 months' do
        it 'computes members of the residue class 0' do
          events = [
            Availability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning),
            Availability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 5.months),
            Availability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 20.months)
          ]

          expect(unique_residues(events)).to eq([0])
        end

        it 'computes members of the residue class 1' do
          events = [
            Availability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 1.month),
            Availability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 6.months),
            Availability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 51.months)
          ]

          expect(unique_residues(events)).to eq([1])
        end

        it 'computes the complete residue system' do
          events = [
            Availability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning),
            Availability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 1.month),
            Availability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 2.months),
            Availability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 3.months),
            Availability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 4.months),
            Availability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 5.months)
          ]

          expect(residues(events)).to eq([0, 1, 2, 3, 4, 0])
        end
      end
    end
  end

  describe '#interval=' do
    it 'updates the residue when the interval changes' do
      event = Availability.create(duration: 45.minutes, interval: 30, start_time: beginning + 10.days)
      event.interval = 9

      expect(event.residue).to eq(1)
    end
  end

  describe '#start_time=' do
    it 'updates the residue when the start_time changes' do
      event = Availability.create(duration: 45.minutes, interval: 30, start_time: beginning + 10.days)
      event.start_time = beginning + 5.days

      expect(event.residue).to eq(5)
    end
  end

  describe '#last_occurrence' do
    context 'when event has no expected stop date' do
      subject { Availability.weekly start_time: Date.today, duration: 4.hours }

      its(:last_occurrence) { should be_nil }
    end

    context 'when event has an expected stop date' do
      context 'weekly' do
        subject { Availability.weekly start_time: Date.today, duration: 4.hours, stops_after: 2 }
        let(:expected_last_occurrence) { (Date.today + 2.weeks).to_time }

        its(:last_occurrence) { should_not be_nil }
        its(:last_occurrence) { should eq expected_last_occurrence }
      end

      context 'daily' do
        subject { Availability.daily start_time: Date.yesterday, duration: 4.hours, stops_after: 2 }
        let(:expected_last_occurrence) { (Date.tomorrow).to_time }

        its(:last_occurrence) { should_not be_nil }
        its(:last_occurrence) { should eq expected_last_occurrence }
      end

      context 'monthly' do
        subject { Availability.monthly start_time: beginning, duration: 8.hours, stops_after: 3 }
        let(:expected_last_occurrence) { (beginning + 3.months).to_time }

        its(:last_occurrence) { should_not be_nil }
        its(:last_occurrence) { should eq expected_last_occurrence }
      end

      context 'yearly' do
        subject { Availability.yearly start_time: beginning, duration: 1.hour, stops_after: 10 }
        let(:expected_last_occurrence) { (beginning + 10.years).to_time }

        its(:last_occurrence) { should_not be_nil }
        its(:last_occurrence) { should eq expected_last_occurrence }
      end

      context 'one time events' do
        it 'stops after one occurrence' do
          event = Availability.once start_time: Date.today, duration: 30.minutes
          expect(event.last_occurrence).to eq Date.today.to_time
        end

        it 'overrides frequency' do
          event = Availability.once frequency: :yearly, start_time: Date.yesterday, duration: 30.minutes
          expect(event.frequency).to eq :once
          expect(event.class).to eq Availability::Once
        end

        it 'creates one time events' do
          event = Availability.create frequency: :once, start_time: Date.yesterday, duration: 30.minutes
          expect(event.class).to eq Availability::Once
        end
      end
    end
  end

  describe '#occurs_at?' do
    context 'when the frequency is daily' do
      context 'when the event is biweekly and starts 5 days after the beginning' do
        let(:event) { Availability.create(duration: 45.minutes, interval: 14, start_time: beginning + 5.days) }

        it 'occurs on its start date' do
          expect(event.occurs_at?(beginning + 5.days)).to be_truthy
        end

        it 'occurs on its next occurrence' do
          expect(event.occurs_at?(beginning + 5.days + 14.days)).to be_truthy
        end

        it 'does not occur on the day after its next occurrence' do
          expect(event.occurs_at?(beginning + 5.days + 15.days)).to be_falsey
        end

        it 'occurs during the duration' do
          expect(event.occurs_at?(beginning + 5.days + 15.minutes)).to be_truthy
        end

        it 'does not occur before the duration' do
          expect(event.occurs_at?(beginning + 5.days - 1.minute)).to be_falsey
        end

        it 'does not occur after the duration' do
          expect(event.occurs_at?(beginning + 5.days + 46.minutes)).to be_falsey
        end
      end

      context 'when the event is every 30 days and starts 11 days after the beginning' do
        let(:event) { Availability.create(duration: 45.minutes, interval: 30, start_time: beginning + 11.days) }

        it 'occurs on its start date' do
          expect(event.occurs_at?(beginning + 11.days)).to be_truthy
        end

        it 'occurs on its next occurrence' do
          expect(event.occurs_at?(beginning + 11.days + 30.days)).to be_truthy
        end

        it 'does not occur on the day before its next occurrence' do
          expect(event.occurs_at?(beginning + 11.days + 29.days)).to be_falsey
        end
      end

      it 'should process events of different intervals on the same day when applicable' do
        event_1 = Availability.create(duration: 45.minutes, interval: 10, start_time: beginning)
        event_2 = Availability.create(duration: 45.minutes, interval: 8, start_time: beginning + 2.days)
        event_3 = Availability.create(duration: 45.minutes, interval: 15, start_time: beginning + 5.days)
        event_4 = Availability.create(duration: 45.minutes, interval: 10, start_time: beginning + 5.days)

        common_date = Time.new(1970, 2, 20)

        expect(event_1.occurs_at?(common_date)).to be_truthy
        expect(event_2.occurs_at?(common_date)).to be_truthy
        expect(event_3.occurs_at?(common_date)).to be_truthy
        expect(event_4.occurs_at?(common_date)).to be_falsey
      end
    end

    context 'when the frequency is monthly' do
      context 'when the event is every 3 months and starts 2 months after the beginning' do
        let(:event) { Availability.create(duration: 45.minutes, frequency: :monthly, interval: 3, start_time: beginning + 2.months) }

        it 'occurs on its start date' do
          expect(event.occurs_at?(beginning + 2.months)).to be_truthy
        end

        it 'occurs on its next occurrence' do
          expect(event.occurs_at?(beginning + 2.months + 3.months)).to be_truthy
        end

        it 'does not occur on the month after its next occurrence' do
          expect(event.occurs_at?(beginning + 2.months + 4.months)).to be_falsey
        end
      end
    end

    context 'when the frequency is yearly' do
      context 'and the event is every 2 years and starts at the beginning' do
        let(:event) { Availability.create(duration: 2.hours, frequency: :yearly, interval: 2, start_time: beginning + 1.year) }

        it 'occurs on its start date' do
          expect(event.occurs_at?(beginning + 1.year)).to be_truthy
        end

        it 'occurs on its next occurrence' do
          expect(event.occurs_at?(beginning + 1.year + 2.years)).to be_truthy
        end

        it 'does not occur on the month after its next occurrence' do
          expect(event.occurs_at?(beginning + 1.year + 3.years)).to be_falsey
        end
      end
    end
  end

  describe '#next_occurrence' do
    context 'when the frequency is daily' do
      context 'when the event is every 21 days and starts 2 days after the beginning' do
        let(:event) { Availability.create(duration: 45.minutes, interval: 21, start_time: beginning + 2.days) }

        it 'calculates the first occurrence' do
          expect(event.next_occurrence(beginning + 2.days)).to eq(beginning + 2.days)
        end

        it 'calculates the next occurrence 1 day later' do
          expect(event.next_occurrence(beginning + 2.days + 1.day)).to eq(beginning + 2.days + 21.days)
        end

        it 'calculates the next occurrence 10 days later' do
          expect(event.next_occurrence(beginning + 2.days + 10.days)).to eq(beginning + 2.days + 21.days)
        end

        it 'calculates the next occurrence on the day of' do
          expect(event.next_occurrence(beginning + 2.days + 21.days)).to eq(beginning + 2.days + 21.days)
        end

        it 'calculates the third occurrence 25 days later' do
          expect(event.next_occurrence(beginning + 2.days + 25.days)).to eq(beginning + 2.days + 42.days)
        end
      end

      context 'when the event is every 10 days and starts 4 days after the beginning' do
        let(:event) { Availability.create(duration: 45.minutes, interval: 10, start_time: beginning + 4.days) }

        it 'calculates the first occurrence' do
          expect(event.next_occurrence(beginning + 4.days)).to eq(beginning + 4.days)
        end

        it 'calculates the next occurrence 1 day later' do
          expect(event.next_occurrence(beginning + 4.days + 1.day)).to eq(beginning + 14.days)
        end

        it 'calculates the next occurrence 9 days later' do
          expect(event.next_occurrence(beginning + 4.days + 9.days)).to eq(beginning + 14.days)
        end

        it 'calculates the next occurrence on the day of' do
          expect(event.next_occurrence(beginning + 4.days + 10.days)).to eq(beginning + 14.days)
        end

        it 'calculates the third occurrence 17 days later' do
          expect(event.next_occurrence(beginning + 4.days + 17.days)).to eq(beginning + 24.days)
        end
      end
    end

    context 'when the frequency is monthly' do
      context 'when the event is every 4 months and starts at the beginning' do
        let(:event) { Availability.create(duration: 45.minutes, frequency: :monthly, interval: 4, start_time: beginning) }

        it 'calculates the first occurrence' do
          expect(event.next_occurrence(beginning)).to eq(beginning)
        end

        it 'calculates the next occurrence 1 month later' do
          expect(event.next_occurrence(beginning + 1.month)).to eq(beginning + 4.months)
        end

        it 'calculates the next occurrence 4 months later' do
          expect(event.next_occurrence(beginning + 4.months)).to eq(beginning + 4.months)
        end

        it 'calculates the next occurrence 5 months later' do
          expect(event.next_occurrence(beginning + 5.months)).to eq(beginning + 8.months)
        end

        it 'calculates the occurrence 25 months later' do
          expect(event.next_occurrence(beginning + 25.months)).to eq(beginning + 28.months)
        end
      end
    end

    context 'when the frequency is yearly' do
      context 'and the event is every 3 years and starts at the beginning' do
        let(:event) { Availability.create(duration: 2.hours, frequency: :yearly, interval: 4, start_time: beginning) }

        it 'calculates the first occurrence' do
          expect(event.next_occurrence(beginning.to_time)).to eq(beginning)
        end

        it 'calculates the next occurrence 1 year later' do
          expect(event.next_occurrence(beginning + 1.year)).to eq(beginning + 4.years)
        end

        it 'calculates the next occurrence 4 years later' do
          expect(event.next_occurrence(beginning + 4.years)).to eq(beginning + 4.years)
        end

        it 'calculates the next occurrence 5 years later' do
          expect(event.next_occurrence(beginning + 5.years)).to eq(beginning + 8.years)
        end

        it 'calculates the occurrence 25 years later' do
          expect(event.next_occurrence(beginning + 25.years)).to eq(beginning + 28.years)
        end
      end
    end
  end

  describe '#next_n_occurrences' do
    context 'when the frequency is daily' do
      context 'when the event is every 7 days and starts 31 days after the beginning' do
        let(:event) { Availability.create(duration: 45.minutes, interval: 7, start_time: beginning + 31.days) }

        it 'calculates the next 5 occurrences 1 day after the first processing' do
          expect(event.next_n_occurrences(5, beginning + 31.days + 1.day)).to eq([
            beginning + 38.days,
            beginning + 45.days,
            beginning + 52.days,
            beginning + 59.days,
            beginning + 66.days
          ])
        end
      end

      context 'when the event is every 40 days and starts 11 days after the beginning' do
        let(:event) { Availability.create(duration: 45.minutes, interval: 40, start_time: beginning + 11.days) }

        it 'calculates the next 3 occurrences 100 days after the first processing' do
          expect(event.next_n_occurrences(3, beginning + 11.days + 100.days)).to eq([
            beginning + 131.days,
            beginning + 171.days,
            beginning + 211.days
          ])
        end
      end
    end

    context 'when the frequency is monthly' do
      context 'when the event is every 7 months and starts 3 months after the beginning' do
        let(:event) { Availability.create(duration: 45.minutes, frequency: :monthly, interval: 7, start_time: beginning + 3.months) }

        it 'calculates the next 5 occurrences 1 month after the first processing' do
          expect(event.next_n_occurrences(5, beginning + 3.months + 1.month)).to eq([
            beginning + 10.months,
            beginning + 17.months,
            beginning + 24.months,
            beginning + 31.months,
            beginning + 38.months
          ])
        end
      end
    end

    context 'performance' do
      let(:event) { Availability.daily(duration: 45.minutes, interval: 7, start_time: beginning + 3.months) }

      it 'calculates next N occurrences quickly' do
        [1, 10, 100, 1000, 10_000, 100_000, 1_000_000].each do |n|
          time = Time.now
          event.next_n_occurrences n, beginning
          time_in_seconds = Time.now.sec - time.sec
          expect(time_in_seconds).to be <= 1, "calculating the next #{n} occurrences is too slow: took #{time_in_seconds}"
        end
      end

      it 'returns a lazy enumerator for N > 1000' do
        expect(event.next_n_occurrences(1001, beginning).class).to be Enumerator::Lazy
      end

      it 'returns an array for N <= 1000' do
        expect(event.next_n_occurrences(1, beginning).class).to be Array
        expect(event.next_n_occurrences(100, beginning).class).to be Array
        expect(event.next_n_occurrences(1000, beginning).class).to be Array
      end
    end

    context '#corresponds_to?' do
      let(:event) { Availability.daily(duration: 45.minutes, start_time: beginning + 3.months) }
      let(:similar_event) { Availability.daily(duration: 45.minutes, start_time: beginning + 3.months) }

      it 'itself' do
        expect(event.corresponds_to? event).to be true
      end

      it 'a similar event' do
        expect(similar_event.corresponds_to? event).to be true
        expect(event.corresponds_to? similar_event).to be true
      end

      it 'someday during middle of event' do
        once = Availability.once(duration: 45.minutes, start_time: beginning + 3.months + 3.days)
        expect(event.corresponds_to? once).to be true
      end

      it 'shorter time period' do
        once = Availability.once(duration: 30.minutes, start_time: beginning + 3.months + 4.days)
        expect(event.corresponds_to? once).to be true
      end

      it 'last day of event' do
        once = Availability.once(duration: 45.minutes, start_time: beginning + 3.months + 7.days)
        expect(event.corresponds_to? once).to be true
      end
    end
  end
end
