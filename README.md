# availability - easily and quickly calculate schedule availability

[![Build Status](https://travis-ci.org/upper-hand/availability.svg?branch=master)](https://travis-ci.org/upper-hand/availability)
[![Gem Version](https://badge.fury.io/rb/availability.svg)](https://badge.fury.io/rb/availability)

This library uses modular arithmetic and residue classes to calculate schedule availability for dates. Time ranges within a date are handled differently. The goal is to create an easy-to-use API for schedule availability that is very fast and lightweight that is also easy and lightweight to persist in a database.

Shout out to @dpmccabe for his [original article](http://dmcca.be/2014/01/09/recurring-subscriptions-with-ruby-rspec-and-modular-arithmetic.html) and code.

```
gem install availability
```

## TODO

add more documentation

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
