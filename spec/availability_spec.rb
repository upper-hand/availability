RSpec.describe Schedulability do
  include SchedulabilitySpecHelpers

  describe '#initialize' do
    context 'Availability' do
      it 'should not be able to instantiate an Availability' do
        expect { Schedulability::Availability.new }.to raise_error NoMethodError
      end
    end

    context 'concrete classes:' do
      let (:args) { {duration: 1.hour, interval: 1, start_time: Date.today} }
      %w{ Once Hourly Daily Weekly Monthly Yearly }.each do |subclass_name|
        it "allows #{subclass_name} to be instantiated" do
          expect { Schedulability.const_get(subclass_name).new **args }.not_to raise_error
        end
      end
    end

    context 'one-time frequency' do
      subject { Schedulability.once(duration: 15.minutes, start_time: Date.tomorrow) }

      its(:interval) { should eq(0) }
      its(:start_time) { should eq(Date.tomorrow.to_time) }
      its(:duration) { should eq(15.minutes) }
    end

    context 'hourly frequency' do
      subject { Schedulability.hourly(duration: 30.minutes, start_time: Date.tomorrow) }

      its(:interval) { should eq(1) }
      its(:start_time) { should eq(Date.tomorrow.to_time) }
      its(:duration) { should eq(30.minutes) }
    end

    context 'defaults to daily frequency' do
      subject { Schedulability.create(duration: 15.minutes, interval: 4, start_time: Date.tomorrow) }

      its(:interval) { should eq(4) }
      its(:start_time) { should eq(Date.tomorrow.to_time) }
      its(:duration) { should eq(15.minutes) }
    end

    context 'daily frequency, every 4 days' do
      subject { Schedulability.daily(duration: 15.minutes, interval: 4, start_time: Date.tomorrow) }

      its(:interval) { should eq(4) }
      its(:start_time) { should eq(Date.tomorrow.to_time) }
      its(:duration) { should eq(15.minutes) }
    end

    context 'weekly frequency' do
      subject { Schedulability.weekly(duration: 15.minutes, interval: 3, start_time: Date.tomorrow) }

      its(:interval) { should eq(21) }
      its(:start_time) { should eq(Date.tomorrow.to_time) }
      its(:duration) { should eq(15.minutes) }
    end

    context 'monthly frequency' do
      subject { Schedulability.monthly(duration: 2.hours, interval: 5, start_time: Date.tomorrow) }

      its(:interval) { should eq(5) }
      its(:start_time) { should eq(Date.tomorrow.to_time) }
      its(:duration) { should eq(2.hours) }
    end

    context 'yearly frequency' do
      subject { Schedulability.yearly(duration: 30.minutes, interval: 2, start_time: Date.tomorrow) }

      its(:interval) { should eq(2) }
      its(:start_time) { should eq(Date.tomorrow.to_time) }
      its(:duration) { should eq(30.minutes) }
    end

    context 'every two|three|four|five factories' do
      {hours: :hourly, days: :daily, weeks: :weekly, months: :monthly, years: :yearly}.each do | factory_suffix, frequency |
        {two: 2, three: 3, four: 4, five: 5}.each do | name, interval |
          it "#every_#{name}_#{factory_suffix}" do
            event = Schedulability.send("every_#{name}_#{factory_suffix}", duration: 1.hour, start_time: Date.today)
            interval *= 7 if frequency == :weekly
            expect(event.interval).to eq interval
            expect(event.duration).to eq 1.hour
          end
        end
      end
    end

    context 'every_other_* factories' do
      {hour: :hourly, day: :daily, week: :weekly, month: :monthly, year: :yearly}.each do | factory_suffix, frequency |
        it "#every_other_#{factory_suffix}" do
          availability = Schedulability.send("every_other_#{factory_suffix}", duration: 1.hour, start_time: Date.today)
          expect(availability.interval).to eq( frequency == :weekly ? 14 : 2 )
          expect(availability.duration).to eq 1.hour
        end
      end
    end
  end

  describe '#residue' do
    context 'when the frequency is daily' do
      context 'when interval is weekly' do
        it 'computes members of the residue class 0' do
          availabilities = [
            Schedulability.create(duration: 45.minutes, interval: 7, start_time: beginning),
            Schedulability.create(duration: 45.minutes, interval: 7, start_time: beginning + 7.days),
            Schedulability.create(duration: 45.minutes, interval: 7, start_time: beginning + 70.days)
          ]

          expect(unique_residues(availabilities)).to eq([0])
        end

        it 'computes members of the residue class 1' do
          availabilities = [
            Schedulability.create(duration: 45.minutes, interval: 7, start_time: beginning + 1.day),
            Schedulability.create(duration: 45.minutes, interval: 7, start_time: beginning + 8.days),
            Schedulability.create(duration: 45.minutes, interval: 7, start_time: beginning + 71.days)
          ]

          expect(unique_residues(availabilities)).to eq([1])
        end

        it 'computes the complete residue system' do
          availabilities = [
            Schedulability.create(duration: 45.minutes, interval: 7, start_time: beginning),
            Schedulability.create(duration: 45.minutes, interval: 7, start_time: beginning + 1.day),
            Schedulability.create(duration: 45.minutes, interval: 7, start_time: beginning + 2.days),
            Schedulability.create(duration: 45.minutes, interval: 7, start_time: beginning + 3.days),
            Schedulability.create(duration: 45.minutes, interval: 7, start_time: beginning + 4.days),
            Schedulability.create(duration: 45.minutes, interval: 7, start_time: beginning + 5.days),
            Schedulability.create(duration: 45.minutes, interval: 7, start_time: beginning + 6.days),
            Schedulability.create(duration: 45.minutes, interval: 7, start_time: beginning + 7.days)
          ]

          expect(residues(availabilities)).to eq([0, 1, 2, 3, 4, 5, 6, 0])
        end
      end

      context 'when interval is every 100 days' do
        it 'computes members of the residue class 0' do
          availabilities = [
            Schedulability.create(duration: 45.minutes, interval: 100, start_time: beginning),
            Schedulability.create(duration: 45.minutes, interval: 100, start_time: beginning + 100.days),
            Schedulability.create(duration: 45.minutes, interval: 100, start_time: beginning + 500.days)
          ]

          expect(unique_residues(availabilities)).to eq([0])
        end

        it 'computes members of the residue class 25' do
          availabilities = [
            Schedulability.create(duration: 45.minutes, interval: 100, start_time: beginning + 25.day),
            Schedulability.create(duration: 45.minutes, interval: 100, start_time: beginning + 125.days),
            Schedulability.create(duration: 45.minutes, interval: 100, start_time: beginning + 525.days)
          ]

          expect(unique_residues(availabilities)).to eq([25])
        end
      end
    end

    context 'when the frequency is monthly' do
      context 'when interval is every 5 months' do
        it 'computes members of the residue class 0' do
          availabilities = [
            Schedulability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning),
            Schedulability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 5.months),
            Schedulability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 20.months)
          ]

          expect(unique_residues(availabilities)).to eq([0])
        end

        it 'computes members of the residue class 1' do
          availabilities = [
            Schedulability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 1.month),
            Schedulability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 6.months),
            Schedulability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 51.months)
          ]

          expect(unique_residues(availabilities)).to eq([1])
        end

        it 'computes the complete residue system' do
          availabilities = [
            Schedulability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning),
            Schedulability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 1.month),
            Schedulability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 2.months),
            Schedulability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 3.months),
            Schedulability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 4.months),
            Schedulability.create(duration: 45.minutes, frequency: :monthly, interval: 5, start_time: beginning + 5.months)
          ]

          expect(residues(availabilities)).to eq([0, 1, 2, 3, 4, 0])
        end
      end
    end
  end

  describe '#interval=' do
    it 'updates the residue when the interval changes' do
      availability = Schedulability.create(duration: 45.minutes, interval: 30, start_time: beginning + 10.days)
      availability.interval = 9

      expect(availability.residue).to eq(1)
    end
  end

  describe '#start_time=' do
    it 'updates the residue when the start_time changes' do
      availability = Schedulability.create(duration: 45.minutes, interval: 30, start_time: beginning + 10.days)
      availability.start_time = beginning + 5.days

      expect(availability.residue).to eq(5)
    end
  end

  describe '#last_occurrence' do
    context 'when availability has no expected stop date' do
      subject { Schedulability.weekly start_time: Date.today, duration: 4.hours }

      its(:last_occurrence) { should be_nil }
    end

    context 'one time availabilities' do
      it 'stops after one occurrence' do
        availability = Schedulability.once start_time: Date.today, duration: 30.minutes
        expect(availability.last_occurrence).to eq Date.today.to_time
        expect(availability.includes? availability.start_time).to be_truthy
      end
    end

    context 'when availability has a stops_by attribute' do
      context 'daily' do
        subject { Schedulability.daily start_time: Date.yesterday, duration: 4.hours, stops_by: expected_last_occurrence }
        let(:expected_last_occurrence) { (Date.tomorrow).to_time }

        its(:last_occurrence) { should_not be_nil }
        its(:last_occurrence) { should eq expected_last_occurrence }

        it 'expects includes?(last_occurrence) to be true' do
          expect(subject.includes? subject.last_occurrence).to be_truthy
        end
      end

      context 'weekly stops on same date as expected last occurrence' do
        subject { Schedulability.weekly start_time: Time.new(1973, 5, 15), duration: 4.hours, stops_by: expected_last_occurrence }
        let(:expected_last_occurrence) { Time.new(1973, 5, 29) }

        its(:last_occurrence) { should_not be_nil }
        its(:last_occurrence) { should eq expected_last_occurrence }

        it 'expects includes?(last_occurrence) to be true' do
          expect(subject.includes? subject.last_occurrence).to be_truthy
        end
      end

      context 'weekly stops by some point in a different residue class' do
        subject { Schedulability.weekly start_time: Time.new(1973, 5, 15), duration: 4.hours, stops_by: expected_last_occurrence + 4.days }
        let(:expected_last_occurrence) { Time.new(1973, 5, 29) }

        its(:last_occurrence) { should_not be_nil }
        its(:last_occurrence) { should eq expected_last_occurrence }

        it 'expects includes?(last_occurrence) to be true' do
          expect(subject.includes? subject.last_occurrence).to be_truthy
        end
      end

      context 'monthly stops on same date as expected last occurrence' do
        subject { Schedulability.monthly start_time: beginning, duration: 8.hours, stops_by: expected_last_occurrence }
        let(:expected_last_occurrence) { (beginning + 3.months).to_time }

        its(:last_occurrence) { should_not be_nil }
        its(:last_occurrence) { should eq expected_last_occurrence }

        it 'expects includes?(last_occurrence) to be true' do
          expect(subject.includes? subject.last_occurrence).to be_truthy
        end
      end

      context 'monthly stops by some point in a different residue class' do
        subject { Schedulability.monthly start_time: beginning, duration: 8.hours, stops_by: expected_last_occurrence + 23.days }
        let(:expected_last_occurrence) { (beginning + 3.months).to_time }

        its(:last_occurrence) { should_not be_nil }
        its(:last_occurrence) { should eq expected_last_occurrence }

        it 'expects includes?(last_occurrence) to be true' do
          expect(subject.includes? subject.last_occurrence).to be_truthy
        end
      end

      context 'yearly stops on same date as expected last occurrence' do
        subject { Schedulability.yearly start_time: beginning, duration: 1.hour, stops_by: expected_last_occurrence + 1.day }
        let(:expected_last_occurrence) { (beginning + 10.years).to_time }

        its(:last_occurrence) { should_not be_nil }
        its(:last_occurrence) { should eq expected_last_occurrence }

        it 'expects includes?(last_occurrence) to be true' do
          expect(subject.includes? subject.last_occurrence).to be_truthy
        end
      end

      context 'yearly stops by some point in a different residue class' do
        subject { Schedulability.yearly start_time: beginning, duration: 1.hour, stops_by: expected_last_occurrence + 3.months + 2.days }
        let(:expected_last_occurrence) { (beginning + 10.years).to_time }

        its(:last_occurrence) { should_not be_nil }
        its(:last_occurrence) { should eq expected_last_occurrence }

        it 'expects includes?(last_occurrence) to be true' do
          expect(subject.includes? subject.last_occurrence).to be_truthy
        end
      end
    end
  end

  describe '#includes?' do
    context 'comparing times' do
      let(:every_other_monday) do
        Schedulability.every_other_week(start_time: Time.new(2016, 5, 2, 9), duration: 1.hour)
      end

      it 'should not include the start of the following hour for a one-hour availability' do
        expect(every_other_monday.includes? Time.new(2016, 5, 30, 10)).to be_falsey
      end
    end

    context 'when the frequency is daily' do
      context 'when the availability is biweekly and starts 5 days after the beginning' do
        let(:availability) { Schedulability.create(duration: 45.minutes, interval: 14, start_time: beginning + 5.days) }

        it 'occurs on its start date' do
          expect(availability.includes?(beginning + 5.days)).to be_truthy
        end

        it 'occurs on its next occurrence' do
          expect(availability.includes?(beginning + 5.days + 14.days)).to be_truthy
        end

        it 'does not occur on the day after its next occurrence' do
          expect(availability.includes?(beginning + 5.days + 15.days)).to be_falsey
        end

        it 'occurs during the duration' do
          expect(availability.includes?(beginning + 5.days + 15.minutes)).to be_truthy
        end

        it 'does not occur before the duration' do
          expect(availability.includes?(beginning + 5.days - 1.minute)).to be_falsey
        end

        it 'does not occur after the duration' do
          expect(availability.includes?(beginning + 5.days + 46.minutes)).to be_falsey
        end
      end

      context 'when the availability is every 30 days and starts 11 days after the beginning' do
        let(:availability) { Schedulability.create(duration: 45.minutes, interval: 30, start_time: beginning + 11.days) }

        it 'occurs on its start date' do
          expect(availability.includes?(beginning + 11.days)).to be_truthy
        end

        it 'occurs on its next occurrence' do
          expect(availability.includes?(beginning + 11.days + 30.days)).to be_truthy
        end

        it 'does not occur on the day before its next occurrence' do
          expect(availability.includes?(beginning + 11.days + 29.days)).to be_falsey
        end
      end

      it 'should process availabilities of different intervals on the same day when applicable' do
        availability_1 = Schedulability.create(duration: 45.minutes, interval: 10, start_time: beginning)
        availability_2 = Schedulability.create(duration: 45.minutes, interval: 8, start_time: beginning + 2.days)
        availability_3 = Schedulability.create(duration: 45.minutes, interval: 15, start_time: beginning + 5.days)
        availability_4 = Schedulability.create(duration: 45.minutes, interval: 10, start_time: beginning + 5.days)

        common_date = Time.new(1970, 2, 20)

        expect(availability_1.includes?(common_date)).to be_truthy
        expect(availability_2.includes?(common_date)).to be_truthy
        expect(availability_3.includes?(common_date)).to be_truthy
        expect(availability_4.includes?(common_date)).to be_falsey
      end
    end

    context 'when the frequency is weekly' do
      context 'when the availability is every week' do
        let(:start_time) { Time.new 2016, 1, 1}
        let(:availability) { Schedulability.weekly(duration: 45.minutes, start_time: start_time) }

        it 'occurs on its start date' do
          expect(availability.includes?(start_time)).to be_truthy
        end

        it 'occurs on its next occurrence' do
          expect(availability.includes?(start_time + 1.week)).to be_truthy
        end

        it 'does not occur on another day of the week' do
          (1..6).each do |i|
            expect(availability.includes?(start_time + i.days)).to be_falsey
          end
        end
      end
    end

    context 'when the frequency is monthly' do
      context 'when the availability is every 3 months and starts 2 months after the beginning' do
        let(:availability) { Schedulability.create(duration: 45.minutes, frequency: :monthly, interval: 3, start_time: beginning + 2.months) }

        it 'occurs on its start date' do
          expect(availability.includes?(beginning + 2.months)).to be_truthy
        end

        it 'occurs on its next occurrence' do
          expect(availability.includes?(beginning + 2.months + 3.months)).to be_truthy
        end

        it 'does not occur on the month after its next occurrence' do
          expect(availability.includes?(beginning + 2.months + 4.months)).to be_falsey
        end
      end
    end

    context 'when the frequency is yearly' do
      context 'and the availability is every 2 years and starts at the beginning' do
        let(:availability) { Schedulability.create(duration: 2.hours, frequency: :yearly, interval: 2, start_time: beginning + 1.year) }

        it 'occurs on its start date' do
          expect(availability.includes?(beginning + 1.year)).to be_truthy
        end

        it 'occurs on its next occurrence' do
          expect(availability.includes?(beginning + 1.year + 2.years)).to be_truthy
        end

        it 'does not occur on the month after its next occurrence' do
          expect(availability.includes?(beginning + 1.year + 3.years)).to be_falsey
        end
      end
    end
  end

  describe '#next_occurrence' do
    context 'when the frequency is daily' do
      context 'when the availability is every 21 days and starts 2 days after the beginning' do
        let(:availability) { Schedulability.create(duration: 45.minutes, interval: 21, start_time: beginning + 2.days) }

        it 'calculates the first occurrence' do
          expect(availability.next_occurrence(beginning + 2.days)).to eq(beginning + 2.days)
        end

        it 'calculates the next occurrence 1 day later' do
          expect(availability.next_occurrence(beginning + 2.days + 1.day)).to eq(beginning + 2.days + 21.days)
        end

        it 'calculates the next occurrence 10 days later' do
          expect(availability.next_occurrence(beginning + 2.days + 10.days)).to eq(beginning + 2.days + 21.days)
        end

        it 'calculates the next occurrence on the day of' do
          expect(availability.next_occurrence(beginning + 2.days + 21.days)).to eq(beginning + 2.days + 21.days)
        end

        it 'calculates the third occurrence 25 days later' do
          expect(availability.next_occurrence(beginning + 2.days + 25.days)).to eq(beginning + 2.days + 42.days)
        end
      end

      context 'when the availability is every 10 days and starts 4 days after the beginning' do
        let(:availability) { Schedulability.create(duration: 45.minutes, interval: 10, start_time: beginning + 4.days) }

        it 'calculates the first occurrence' do
          expect(availability.next_occurrence(beginning + 4.days)).to eq(beginning + 4.days)
        end

        it 'calculates the next occurrence 1 day later' do
          expect(availability.next_occurrence(beginning + 4.days + 1.day)).to eq(beginning + 14.days)
        end

        it 'calculates the next occurrence 9 days later' do
          expect(availability.next_occurrence(beginning + 4.days + 9.days)).to eq(beginning + 14.days)
        end

        it 'calculates the next occurrence on the day of' do
          expect(availability.next_occurrence(beginning + 4.days + 10.days)).to eq(beginning + 14.days)
        end

        it 'calculates the third occurrence 17 days later' do
          expect(availability.next_occurrence(beginning + 4.days + 17.days)).to eq(beginning + 24.days)
        end
      end
    end

    context 'when the frequency is monthly' do
      context 'when the availability is every 4 months and starts at the beginning' do
        let(:availability) { Schedulability.create(duration: 45.minutes, frequency: :monthly, interval: 4, start_time: beginning) }

        it 'calculates the first occurrence' do
          expect(availability.next_occurrence(beginning)).to eq(beginning)
        end

        it 'calculates the next occurrence 1 month later' do
          expect(availability.next_occurrence(beginning + 1.month)).to eq(beginning + 4.months)
        end

        it 'calculates the next occurrence 4 months later' do
          expect(availability.next_occurrence(beginning + 4.months)).to eq(beginning + 4.months)
        end

        it 'calculates the next occurrence 5 months later' do
          expect(availability.next_occurrence(beginning + 5.months)).to eq(beginning + 8.months)
        end

        it 'calculates the occurrence 25 months later' do
          expect(availability.next_occurrence(beginning + 25.months)).to eq(beginning + 28.months)
        end
      end
    end

    context 'when the frequency is yearly' do
      context 'and the availability is every 3 years and starts at the beginning' do
        let(:availability) { Schedulability.create(duration: 2.hours, frequency: :yearly, interval: 4, start_time: beginning) }

        it 'calculates the first occurrence' do
          expect(availability.next_occurrence(beginning.to_time)).to eq(beginning)
        end

        it 'calculates the next occurrence 1 year later' do
          expect(availability.next_occurrence(beginning + 1.year)).to eq(beginning + 4.years)
        end

        it 'calculates the next occurrence 4 years later' do
          expect(availability.next_occurrence(beginning + 4.years)).to eq(beginning + 4.years)
        end

        it 'calculates the next occurrence 5 years later' do
          expect(availability.next_occurrence(beginning + 5.years)).to eq(beginning + 8.years)
        end

        it 'calculates the occurrence 25 years later' do
          expect(availability.next_occurrence(beginning + 25.years)).to eq(beginning + 28.years)
        end
      end
    end

    context 'when there are exclusions' do
      let(:july_fourth) { Time.new 2015, 7, 4, 10 }

      context 'daily' do
        let(:the_day_before) { july_fourth - 1.day }
        let(:the_day_after) { july_fourth + 1.day }
        let(:the_second_day_after) { july_fourth + 2.days }
        let(:the_third_day_after) { july_fourth + 3.days }
        let(:availability) {
          Schedulability.daily(duration: 1.hour, start_time: the_day_before, stops_by: the_third_day_after).tap do |a|
            a.exclusions = Schedulability::Exclusion.all_day july_fourth
          end
        }

        it 'counts the day before July 4th as the next occurrence' do
          expect(availability.next_occurrence(the_day_before)).to eq the_day_before
          expect(availability.next_occurrence(the_day_before - 1.day)).to eq the_day_before
        end

        it 'excludes the holiday' do
          expect(availability.next_occurrence(the_day_before + 1.day)).to eq the_day_after
        end

        it 'counts the 2nd day after July 4th as the next occurrence' do
          expect(availability.next_occurrence(the_day_after + 1.day)).to eq the_second_day_after
        end

        it 'counts the 3rd day after July 4th as the next occurrence' do
          expect(availability.next_occurrence(the_second_day_after + 1.day)).to eq the_third_day_after
        end

        it 'stops after the 3rd day after July 4th' do
          expect(availability.next_occurrence(the_third_day_after + 1.day)).to be nil
        end

        context 'modeling business days' do
          let(:business_days) do
            Schedulability.hourly(
              start_time: Time.new(2016, 1, 1, 8),
              duration: 1.hour,
              exclusions: [Schedulability::Exclusion.new(SchedulabilitySpecHelpers::BusinessDayRule.new)]
            )
          end
          let(:monday_at_10_am) { Time.new(2016, 5, 2, 10) }
          let(:before_time) { Time.new(2023, 2, 23, 7) }
          let(:after_time) { Time.new(2091, 8, 13, 19) }

          it 'occurs during normal business hours' do
            expect(business_days.includes? monday_at_10_am).to be_truthy
          end

          it 'does not occur before normal business hours' do
            expect(business_days.includes? before_time).to be_falsey
          end

          it 'does not occur after normal business hours' do
            expect(business_days.includes? after_time).to be_falsey
          end
        end
      end

      context 'weekly' do
        let(:the_week_before) { july_fourth - 1.week }
        let(:the_week_after) { july_fourth + 1.week }
        let(:the_second_week_after) { july_fourth + 2.weeks }
        let(:the_third_week_after) { july_fourth + 3.weeks }
        let(:availability) {
          Schedulability.weekly(duration: 1.hour, start_time: the_week_before, stops_by: the_third_week_after).tap do |a|
            a.exclusions = Schedulability::Exclusion.all_day july_fourth
          end
        }

        it 'counts the week before July 4th as the next occurrence' do
          expect(availability.next_occurrence(the_week_before)).to eq the_week_before
          expect(availability.next_occurrence(the_week_before - 1.week)).to eq the_week_before
        end

        it 'excludes the holiday' do
          expect(availability.next_occurrence(the_week_before + 1.day)).to eq the_week_after
        end

        it 'counts the 2nd week after July 4th as the next occurrence' do
          expect(availability.next_occurrence(the_week_after + 1.day)).to eq the_second_week_after
        end

        it 'counts the 3rd week after July 4th as the next occurrence' do
          expect(availability.next_occurrence(the_second_week_after + 1.day)).to eq the_third_week_after
        end

        it 'stops after the 3rd week after July 4th' do
          expect(availability.next_occurrence(the_third_week_after + 1.day)).to be nil
        end
      end
    end
  end

  describe '#next_n_occurrences' do
    context 'when the frequency is daily' do
      context 'when the availability is every 7 days and starts 31 days after the beginning' do
        let(:availability) { Schedulability.create(duration: 45.minutes, interval: 7, start_time: beginning + 31.days) }

        it 'calculates the next 5 occurrences 1 day after the first processing' do
          expect(availability.next_n_occurrences(5, beginning + 31.days + 1.day)).to eq([
            beginning + 38.days,
            beginning + 45.days,
            beginning + 52.days,
            beginning + 59.days,
            beginning + 66.days
          ])
        end
      end

      context 'when the availability is every 40 days and starts 11 days after the beginning' do
        let(:availability) { Schedulability.create(duration: 45.minutes, interval: 40, start_time: beginning + 11.days) }

        it 'calculates the next 3 occurrences 100 days after the first processing' do
          expect(availability.next_n_occurrences(3, beginning + 11.days + 100.days)).to eq([
            beginning + 131.days,
            beginning + 171.days,
            beginning + 211.days
          ])
        end
      end
    end

    context 'when the frequency is monthly' do
      context 'when the availability is every 7 months and starts 3 months after the beginning' do
        let(:availability) { Schedulability.create(duration: 45.minutes, frequency: :monthly, interval: 7, start_time: beginning + 3.months) }

        it 'calculates the next 5 occurrences 1 month after the first processing' do
          expect(availability.next_n_occurrences(5, beginning + 3.months + 1.month)).to eq([
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
      let(:availability) { Schedulability.daily(duration: 45.minutes, interval: 7, start_time: beginning + 3.months) }

      it 'calculates next N occurrences quickly' do
        [1, 10, 100, 1000, 10_000, 100_000, 1_000_000].each do |n|
          time = Time.now
          availability.next_n_occurrences n, beginning
          time_in_seconds = Time.now.sec - time.sec
          expect(time_in_seconds).to be <= 1, "calculating the next #{n} occurrences is too slow: took #{time_in_seconds}"
        end
      end

      it 'returns a lazy enumerator for N > 1000' do
        expect(availability.next_n_occurrences(1001, beginning).class).to be Enumerator::Lazy
      end

      it 'returns an array for N <= 1000' do
        expect(availability.next_n_occurrences(1, beginning).class).to be Array
        expect(availability.next_n_occurrences(100, beginning).class).to be Array
        expect(availability.next_n_occurrences(1000, beginning).class).to be Array
      end
    end

    context '#corresponds_to?' do
      let(:availability) { Schedulability.daily(duration: 45.minutes, start_time: beginning + 3.months) }
      let(:similar_availability) { Schedulability.daily(duration: 45.minutes, start_time: beginning + 3.months) }

      it 'itself' do
        expect(availability.corresponds_to? availability).to be true
      end

      context 'when it overlaps the incoming availability' do
        let(:smaller_one) { Schedulability.daily(duration: 15.minutes, start_time: beginning + 3.months + 15.minutes) }
        it { expect(availability.corresponds_to? smaller_one).to be true }
      end

      it 'a similar availability' do
        expect(similar_availability.corresponds_to? availability).to be true
        expect(availability.corresponds_to? similar_availability).to be true
      end

      it 'someday during middle of availability' do
        once = Schedulability.once(duration: 45.minutes, start_time: beginning + 3.months + 3.days)
        expect(availability.corresponds_to? once).to be true
      end

      it 'shorter time period' do
        once = Schedulability.once(duration: 30.minutes, start_time: beginning + 3.months + 4.days)
        expect(availability.corresponds_to? once).to be true
      end

      it 'last day of availability' do
        once = Schedulability.once(duration: 45.minutes, start_time: beginning + 3.months + 7.days)
        expect(availability.corresponds_to? once).to be true
      end
    end
  end
end
