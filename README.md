# Resque::Kalashnikov - fast, fiber-based URL hitter for Resque

[![screenshot](http://www.diigo.com/item/image/2aamo/iubn)](http://www.diigo.com/item/image/2aamo/iubn?size=o)

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

1. Start it as normal Resque

    QUEUE='async_queue,sync_queue' bundle exec rake environment resque:fire

2. Enqueue ResqueKalashnikov::HttpRequest.

    Resque.enqueue ResqueKalashnikov::HttpRequest, 'http://localhost:8081/', {http_method: 'post', foo: 'bar'}

By default it retries all http codes in range 300-600 3 times. For customizing it do your own job.

    class SlowHttpRequest < ResqueKalashnikov::HttpRequest
      @queue = :some_async_queue
      @retry_limit = 5 
    end

Note, that @queue **must** match /async/

## Testing

Test suite is provided with a small EM test webserver. It can be run
manyally for acceptance tests without mocking the web.

Again, thanks @igrigorik!

Besides it's delay option, now it can also randomize HTTP anwser codes:

    ruby spec/support/stub_server.rb 200 404 500

It runs on http://localhost:8081 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
