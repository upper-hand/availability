require 'active_support'
require 'active_support/core_ext'
require_relative 'recurring_event/createable'
require_relative 'recurring_event/abstract_event'
require_relative 'recurring_event/daily'
require_relative 'recurring_event/weekly'
require_relative 'recurring_event/monthly'
require_relative 'recurring_event/yearly'
require_relative 'recurring_event/once'
require_relative 'recurring_event/class_methods'
require_relative 'recurring_event/factory_methods'

# shamelessly adapted from the following article
# http://dmcca.be/2014/01/09/recurring-subscriptions-with-ruby-rspec-and-modular-arithmetic.html
module RecurringEvent
  class AbstractEvent
    extend FactoryMethods
    extend ClassMethods
  end
end
