# NestedText Ruby Library [![Tweet](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=NestedText,%20the%20human%20friendly%20data%20format,%20has%20a%20now%20a%20ruby%20library%20for%20easy%20encoding%20and%20decoding&url=https://github.com/erikw/nestedtext-ruby&via=erik_westrup&hashtags=nestedtext,ruby,gem)
[![Gem Version](https://badge.fury.io/rb/nestedtext.svg)](https://badge.fury.io/rb/nestedtext)
[![Gem Downloads](https://ruby-gem-downloads-badge.herokuapp.com/nestedtext?color=brightgreen&type=total&label=gem%20downloads)](https://rubygems.org/gems/nestedtext)
[![Data Format Version Supported](https://img.shields.io/badge/%F0%9F%84%BD%F0%9F%85%83%20Version%20Supported-3.2.1-blueviolet)](https://nestedtext.org/en/v3.2/)
[![Official Tests](https://img.shields.io/badge/%F0%9F%8F%81%20Official%20Tests-Passing-success)](https://github.com/KenKundert/nestedtext_tests/tree/585e95a73d94ac1f48e71a154e2db0ab67cf30fa)
[![GitHub Actions: Continuous Integration](https://github.com/erikw/nestedtext-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/erikw/nestedtext-ruby/actions/workflows/ci.yml)
[![GitHub Actions: Continuous Deployment](https://github.com/erikw/nestedtext-ruby/actions/workflows/cd.yml/badge.svg)](https://github.com/erikw/nestedtext-ruby/actions/workflows/cd.yml)
[![GitHub Actions: CodeQL Analysis](https://github.com/erikw/nestedtext-ruby/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/erikw/nestedtext-ruby/actions/workflows/codeql-analysis.yml)
[![Code Climate Maintainability](https://api.codeclimate.com/v1/badges/8409b6cdc3dc62a33f6f/maintainability)](https://codeclimate.com/github/erikw/nestedtext-ruby/maintainability)
[![Code Climate Test Coverage](https://api.codeclimate.com/v1/badges/8409b6cdc3dc62a33f6f/test_coverage)](https://codeclimate.com/github/erikw/nestedtext-ruby/test_coverage)
[![SLOC](https://img.shields.io/tokei/lines/github/erikw/nestedtext-ruby)](#)
[![License](https://img.shields.io/github/license/erikw/nestedtext-ruby)](LICENSE.txt)
[![OSS Lifecycle](https://img.shields.io/osslifecycle/erikw/nestedtext-ruby)](https://github.com/Netflix/osstracker)


Inspired by the `JSON` and `YAML` modules.

This project will soon be released! :tada:

On-going development is at branch [**dev**](https://github.com/erikw/nestedtext-ruby/tree/dev).

# What is NestedText?
TODO

https://nestedtext.org/en/latest/alternatives.html

## Examples
TODO NT examples

# Usage
TODO Link to lib docs
TODO link to my test repo showin live usage. https://github.com/erikw/nestedtext-ruby-test


# Usage
## Decoding (reading NT)

## Encoding (writing NT)

`#to_nt` method:
```irb
irb> require 'nestedtext'
irb> puts "a\nstring".to_nt
> a
> string
irb> puts ["i1", "i2", "i3"].to_nt
- i1
- i2
- i3
irb> puts({"k1" => "v1", "multiline\nkey" => "v2", "k3" => "multiline\nvalue"}.to_nt)
k1: v1
: multiline
: key
    > v2
k3:
    > multiline
    > value
```
## Custom Classes Serialization
This library has support for serialization/deserialization of custom classes as well.
`strict: false` flag needed
See [encode_custom_classes_test.rb](test/nestedtext/encode_custom_classes_test.rb) for more real working examples.


# Installation
1. Add this gem to your ruby project's Gemfile
   - Simply with `$ bundle add nestedtext` when standing in the project root
   - Or manually by adding to `Gemfile`
   ```ruby
     gem 'nestedtext'
   ```
   and then running `$ bundle install`.
   ```
1. Require the library and start using it!
   ```ruby
     require 'nestedtext'

     NestedText::load(...)
     NestedText::dump(...)
     obj.to_nt
   ```



# Development

1. Clone the repo
   ```console
   $ git clone https://github.com/erikw/nestedtext-ruby.git && cd $(basename "$_" .git)
   ```
1. Install a supported ruby version (see .gemspec) with a ruby version manager e.g. [rbenv](https://github.com/rbenv/rbenv), [asdf](http://asdf-vm.com/) or [RVM](https://rvm.io/rvm/install)
1. run `$ script/setup` to install dependencies
1. run `$ script/test` to run the tests
1. You can also run `$ script/console` for an interactive prompt that will allow you to experiment.
1. For local testing, install the gem on local machine with: `$ bundle exec rake install`.
   * or manuall with `$ gem build *.gemscpec && gem install *.gem`

Make sure that only intended constants and methods are exposed from the module `NestedText`. Check with
```
irb> require 'nestedtext'
irb> NestedText.constants
irb> NestedText.methods(false)
```

## Releasing
Instructions for releasing on rubygems.org below. Optionally make a GitHub [release](https://github.com/erikw/nestedtext-ruby/releases) after this for the pushed git tag.

## (manually) Using bundler/gem_tasks rake tasks
Following instructions from [bundler.io](https://bundler.io/guides/creating_gem.html#releasing-the-gem):
```console
$ vi -p lib/nestedtext/version.rb CHANGELOG.md
$ bundle exec rake build
$ ver=$(ruby -r ./lib/nestedtext/version.rb -e 'puts NestedText::VERSION')
$ bundle exec rake release
```

## (semi-manually) Using gem-release gem extension
Using [gem-release](https://github.com/svenfuchs/gem-release):
```console
$ vi CHANGELOG.md && git commit -am "Update CHANGELOG.md" && git push
$ gem bump --version minor --tag --sign --push --release
```
For `--version`, use `major|minor|patch` as needed.

## (semi-automatic, preferred) Using GitHub Actions CD
Just push a new semver tag and the workflow [cd.yml](.github/workflows/cd.yml) will publish a new release at rubygems.org.

```console
$ vi -p lib/nestedtext/version.rb CHANGELOG.md
$ git commit -am "Prepare vX.Y.Z" && git push
$ git tag x.y.z && git push --tags
```

or combined with gem-release
```console
$ vi CHANGELOG.md
$ git commit -am "Update CHANGELOG.md" && git push
$ gem bump --version minor --tag --sign --push
```


# Contributing
Bug reports and pull requests are welcome on GitHub at [https://github.com/erikw/nestedtext-ruby](https://github.com/erikw/nestedtext-ruby).

# License
The gem is available as open source with the [License](./LICENSE.txt).

# Acknowledgement & Thanks
Thanks to the data format authors making it easier making new implementations by providing an [official test suite](https://github.com/KenKundert/nestedtext_tests).
