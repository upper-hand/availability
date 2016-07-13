shared_examples_for 'InstanceVariableComparability#<=>' do
  it 'should compare to a similar instance' do
    a = factory[*args_array_for_instance_a]
    b = factory[*args_array_for_instance_a]
    expect(a <=> b).to eq 0
  end

  it 'should compare to itself' do
    a = factory[*args_array_for_instance_a]
    expect(a <=> a).to eq 0

    b = factory[*args_array_for_instance_b]
    expect(b <=> b).to eq 0
  end

  it 'should compare greater' do
    a = factory[*args_array_for_greater_instance]
    b = factory[*args_array_for_lesser_instance]
    expect(a <=> b).to eq 1
  end

  it 'should compare lesser' do
    a = factory[*args_array_for_instance_a]
    b = factory[*args_array_for_instance_b]
    expect(a <=> b).to eq -1
  end

  context 'nil' do
    it 'should compare greater' do
      a = factory[*args_array_for_instance_a]
      expect(a <=> nil).to eq 1
    end

    it 'should compare as nil' do
      a = factory[*args_array_for_instance_a]
      expect(nil <=> a).to eq nil
    end
  end
end

shared_examples_for 'InstanceVariableComparability#==' do
  it 'should be equal to a similar instance' do
    a = factory[*args_array_for_instance_a]
    b = factory[*args_array_for_instance_a]
    expect(a).to eq b
    expect(b).to eq a
  end

  it 'should equal itself' do
    a = factory[*args_array_for_instance_a]
    b = factory[*args_array_for_instance_b]
    expect(a).to eq a
    expect(b).to eq b
  end

  it 'should not equal a different instance' do
    a = factory[*args_array_for_instance_a]
    b = factory[*args_array_for_instance_b]
    expect(a).not_to eq b
    expect(b).not_to eq a
  end

  it 'should not be equal to nil' do
    a = factory[*args_array_for_instance_a]
    expect(a).not_to eq nil
    expect(nil).not_to eq a
  end
end
