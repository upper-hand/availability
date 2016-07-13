require 'active_support'
require 'active_support/core_ext'
require_relative 'schedulability/version'
require_relative 'schedulability/instance_variable_comparability'
require_relative 'schedulability/createable'
require_relative 'schedulability/exclusion'
require_relative 'schedulability/availability'
require_relative 'schedulability/hourly'
require_relative 'schedulability/daily'
require_relative 'schedulability/weekly'
require_relative 'schedulability/monthly'
require_relative 'schedulability/yearly'
require_relative 'schedulability/once'
require_relative 'schedulability/class_methods'
require_relative 'schedulability/factory_methods'

# shamelessly adapted from the following article
# http://dmcca.be/2014/01/09/recurring-subscriptions-with-ruby-rspec-and-modular-arithmetic.html
module Schedulability
  class Availability
    extend FactoryMethods
    extend ClassMethods
  end
end
