$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rspec/its'
require 'schedulability'
require 'yaml'
require 'support/instance_variable_comparability_behavior'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  config.disable_monkey_patching!

  # config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  # config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
end

module SchedulabilitySpecHelpers
  def residues(availabilities)
    availabilities.map(&:residue)
  end

  def unique_residues(availabilities)
    availabilities.map(&:residue).uniq
  end

  def beginning
    Schedulability.beginning.to_time
  end

  class BusinessDayRule
    def initialize
      @not_on_sunday = Schedulability::Exclusion.on_day_of_week(0)
      @not_on_saturday = Schedulability::Exclusion.on_day_of_week(6)
      @after_work_hours = Schedulability::Exclusion.after_time(Time.parse('18:00'))
      @before_work_hours = Schedulability::Exclusion.before_time(Time.parse('08:00'))
    end

    def violated_by?(time)
      @not_on_saturday.violated_by?(time) ||
        @not_on_sunday.violated_by?(time) ||
        @after_work_hours.violated_by?(time) ||
        @before_work_hours.violated_by?(time)
    end
  end
end
