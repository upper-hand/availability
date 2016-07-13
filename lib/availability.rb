require 'active_support'
require 'active_support/core_ext'
require_relative 'availability/version'
require_relative 'availability/instance_variable_comparability'
require_relative 'availability/createable'
require_relative 'availability/exclusion'
require_relative 'availability/abstract_availability'
require_relative 'availability/hourly'
require_relative 'availability/daily'
require_relative 'availability/weekly'
require_relative 'availability/monthly'
require_relative 'availability/yearly'
require_relative 'availability/once'
require_relative 'availability/class_methods'
require_relative 'availability/factory_methods'

# shamelessly adapted from the following article
# http://dmcca.be/2014/01/09/recurring-subscriptions-with-ruby-rspec-and-modular-arithmetic.html
module Availability
  class AbstractAvailability
    extend FactoryMethods
    extend ClassMethods
  end
end
