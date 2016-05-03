# availability
(easily and quickly calculate schedule availability)

[![Build Status](https://travis-ci.org/upper-hand/availability.svg?branch=master)](https://travis-ci.org/upper-hand/availability)
[![Gem Version](https://badge.fury.io/rb/availability.svg)](https://badge.fury.io/rb/availability)
[read the docs][DOCS]

This library uses modular arithmetic and residue classes to calculate schedule availability for dates. Time ranges within a date are handled differently. The goal is to create an easy-to-use API for schedule availability that is very fast and lightweight that is also easy and lightweight to persist in a database.

Shout out to @dpmccabe for his [original article](http://dmcca.be/2014/01/09/recurring-subscriptions-with-ruby-rspec-and-modular-arithmetic.html) and code.

```
gem install availability
```

Creating `Availability` instances is pretty simple. There are 5 variants of availabilities: `Availability::Once`, `Availability::Daily`, `Availability::Weekly`, `Availability::Monthly`, and `Availability::Yearly`. You can instantiate either of those directly (with the `#new` method), or you can use the equivalent factory methods exposed on `Availability` (e.g. `Availability.once`, `Availability.yearly`). Most availabilities will require at least an `interval`, a `start_time`, and a `duration` (see the [RDocs](http://www.rubydoc.info/gems/availability/Availability/AbstractAvailability#initialize-instance_method) for explanations of these).

There are a few convenience factory methods beyond the main factory methods:
  - `Availability.every_{day,week,month,year}` will create the appropriate availability with an interval of 1
  - `Availability.every_two_{days,weeks,months,years}` and `Availability.every_other_{day,week,month,year}` will create the appropriate availability with an interval of 2
  - There are other `every_*` factory methods for intervals of 3, 4, and 5 (e.g. `every_three_months`)

## Primary API

### [#occurs_at?/1][OCCURS_AT]
This method takes a date or time and responds with a boolean indicating whether or not it is covered by the receiver.

### [#corresponds_to?/1][CORRESPONDS_TO]
This method takes another availability and responds with a boolean indicating whether or not it is covered by the receiver.

### [#last_occurrence][LAST_OCCURRENCE]
This returns the last occurrence of the receiver, or `nil` if `stops_by` is not set.

### [#next_n_occurrences/2][NEXT_N_OCCURS]
This returns an enumerable object of the next `N` occurrences of this availability from the given date or time. If `N` is greater than 1,000 a lazy enumerable is returned, otherwise the enumerable is an instance of `Array` with the occurrences.

### [#next_occurrence/1][NEXT_OCCUR]
This returns a single time object for the next occurrence on or after the given date or time. If no occurrence exists, `nil` is returned.

## Examples

```ruby
# Every Monday from 9:00 AM to 10:00 AM starting on May 2, 2016
Availability.every_other_week(start_time: Time.new(2016, 5, 2, 9), duration: 1.hour)

# A business week starting on May 2, 2016 going from 1:30 PM until 2:00 PM every day
Availability.daily(start_time: Time.new(2016, 5, 2, 13, 30), stops_by: Time.new(2016, 5, 6), duration: 30.minutes)

# A semi-monthly availability occurring all day, without an end
Availability.every_other_month(start_time: Time.new(2016, 1, 1), duration: 1.day)
```

## TODO

* add more documentation

## Authors

* Jason Rogers <jacaetevha@gmail.com>

## Contributors

* Jason Rogers <jacaetevha@gmail.com>

## Contributing

* Do your best to adhere to the existing coding conventions and idioms.
* Don't use hard tabs, and don't leave trailing whitespace on any line.
  Before committing, run `git diff --check` to make sure of this.
* Do document every method you add using [YARD][] annotations. Read the
  [tutorial][YARD-GS] or just look at the existing code for examples.
* Don't touch the `availability.gemspec` or `VERSION` files. If you need
  to change them, do so on your private branch only.
* Do feel free to add yourself to the `CREDITS` file and the
  corresponding list in the the `README`. Alphabetical order applies.
* Don't touch the `AUTHORS` file. If your contributions are significant
  enough, be assured we will eventually add you in there.
* Do note that in order for us to merge any non-trivial changes (as a rule
  of thumb, additions larger than about 15 lines of code), we need an
  explicit on record from you. You can submit this dedication as a GitHub
  Issue in this repository. See [public domain dedication][PDD] for an example.

## License

This is free and unencumbered public domain software. For more information,
see <http://unlicense.org/> or the accompanying [UNLICENSE]{UNLICENSE} file.

[YARD]:             http://yardoc.org/
[YARD-GS]:          http://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[PDD]:              http://lists.w3.org/Archives/Public/public-rdf-ruby/2010May/0013.html
[DOCS]:             http://www.rubydoc.info/gems/availability
[OCCURS_AT]:        http://www.rubydoc.info/gems/availability/Availability/AbstractAvailability#occurs_at%3F-instance_method
[CORRESPONDS_TO]:   http://www.rubydoc.info/gems/availability/Availability/AbstractAvailability#corresponds_to%3F-instance_method
[LAST_OCCURRENCE]:  http://www.rubydoc.info/gems/availability/Availability/AbstractAvailability#last_occurrence-instance_method
[NEXT_N_OCCURS]:    http://www.rubydoc.info/gems/availability/Availability/AbstractAvailability#next_n_occurrences%3F-instance_method
[NEXT_OCCUR]:       http://www.rubydoc.info/gems/availability/Availability/AbstractAvailability#next_occurrence%3F-instance_method
