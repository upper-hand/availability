class InstanceVariableComparability
  include Comparable
  def <=>(other)
    return 1 if other.nil?
    comparisons = comparability_ivar_names.map do |ivar|
      instance_variable_get(ivar) <=> other.instance_variable_get(ivar)
    end.reject { |c| c == 0 }
    return 0 if comparisons.empty?
    comparisons.inject(0) { |acc, each| acc + each } >= 1 ? 1 : -1
  end

  protected
  def comparability_ivar_names
    instance_variables
  end
end
