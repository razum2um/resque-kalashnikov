# Resque::Kalashnikov - fast, fiber-based URL hitter for Resque

## Warnings

* It's EM, bro! Don't call sleep and other blocking stuff inside your
  job's methods!

* For database-related tasks consider running some of adapters
  from https://github.com/igrigorik/em-synchrony (thanks @igrigorik!) or 
  just have 2 Resques running different queues and reschedule

* This gem manually handles GC. *It must be disabled during the main loop.*
  It's enabled internally each time before Redis poll. So, huge (ActiveRecord
  fetch from database * many times at once) can be painful for RAM

* Resque's INTERVAL is yet meaningless. It's 0. Redis is polled with blpop.
  As such, please, set infinite timeout for server:

    # /etc/redis.conf
    timeout = 0

* Currently, you cannot do QUEUE= * Please, list your queues

* Beware hash ordering in enqueue options. If failed, these tasks would
  be encountered *differently*. Retried twice, if applicable. Sort it yourself.

    Resque.enqueue ResqueKalashnikov::HttpRequest, 'http://some-url', a:1, b:2
    Resque.enqueue ResqueKalashnikov::HttpRequest, 'http://some-url', b:2, a:1

* Be sure your Resque is not running while testing. And don't run tests
  on production env

## Installation

Add this line to your application's Gemfile:

    gem 'resque-kalashnikov', require: 'resque_kalashnikov'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resque-kalashnikov

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
