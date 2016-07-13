RSpec.describe Availability::Exclusion do
  describe '::Rule' do
    include_examples 'InstanceVariableComparability#<=>' do
      let(:factory) { lambda { |date| Availability::Exclusion.after_day(date) } }
      let(:args_array_for_instance_a) { args_array_for_lesser_instance }
      let(:args_array_for_instance_b) { args_array_for_greater_instance }
      let(:args_array_for_lesser_instance) { [Date.today] }
      let(:args_array_for_greater_instance) { [Date.tomorrow] }
    end

    include_examples 'InstanceVariableComparability#==' do
      let(:factory) { lambda { |date| Availability::Exclusion.before_day(date) } }
      let(:args_array_for_instance_a) { [Date.today] }
      let(:args_array_for_instance_b) { [Date.tomorrow] }
    end

    context 'serialization' do
      let(:factory) { lambda { |date| Availability::Exclusion.all_day(date) } }

      it 'should deserialize to similar object' do
        a = factory[Date.today]
        expect(YAML.load(YAML.dump a)).to eq a
      end

      it 'should not equal a different object when deserialized' do
        a = factory[Date.today]
        b = factory[Date.tomorrow]
        expect(YAML.load(YAML.dump a)).not_to eq b
        expect(b).not_to eq YAML.load(YAML.dump a)
      end

      it 'should deserialize an array of exclusions' do
        coll = [factory[Date.today], factory[Date.tomorrow]]
        expect(YAML.load(YAML.dump coll)).to eq coll
        expect(coll).to eq YAML.load(YAML.dump coll)
      end

      it 'should deserialize a hash of exclusions' do
        coll = {a: factory[Date.today], b: factory[Date.tomorrow]}
        expect(YAML.load(YAML.dump coll)).to eq coll
        expect(coll).to eq YAML.load(YAML.dump coll)
      end
    end
  end
end
