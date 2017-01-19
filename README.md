# Mixlib::Archive
[![Build Status Master](https://travis-ci.org/chef/mixlib-archive.svg?branch=master)](https://travis-ci.org/chef/mixlib-archive)

A very simple gem to extract archives.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mixlib-archive'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mixlib-archive

## Usage

To extract an archive

```ruby
tar = Mixlib::Artifact.new("/path/to/tar")
tar.extract("/destination/directory")
```

To create an archive

```ruby
tar = Mixlib::Artifact.new("/path/to/foo.tar.gz")
tar.create(%w{ file.rb file2.rb }, gzip: true)
```

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bundle console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chef/mixlib-archive. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Community Guidelines](https://docs.chef.io/community_guidelines.html) code of conduct.


## License

The gem is available as open source under the terms of the Apache License, v2

