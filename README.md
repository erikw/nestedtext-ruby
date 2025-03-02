# NestedText Ruby Library [![Tweet](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=NestedText,%20the%20human%20friendly%20data%20format,%20has%20a%20now%20a%20ruby%20library%20for%20easy%20encoding%20and%20decoding&url=https://github.com/erikw/nestedtext-ruby&via=erik_westrup&hashtags=nestedtext,ruby,gem)
[![Gem Version](https://badge.fury.io/rb/nestedtext.svg)](https://badge.fury.io/rb/nestedtext)
[![Gem Downloads](https://img.shields.io/gem/dt/nestedtext?label=gem%20downloads)](https://rubygems.org/gems/nestedtext)
[![Documentation](https://img.shields.io/badge/docs-API-informational?logo=readthedocs&logoColor=violet)](https://www.rubydoc.info/gems/nestedtext/NestedText)
[![Data Format Version Supported](https://img.shields.io/badge/%F0%9F%84%BD%F0%9F%85%83%20Version%20Supported-3.4.0-blueviolet)](https://nestedtext.org/en/v3.3/)
[![Official Tests](https://img.shields.io/badge/Official%20Tests-Passing-success?logo=cachet)](https://github.com/KenKundert/nestedtext_tests/)
[![GitHub Actions: Continuous Integration](https://github.com/erikw/nestedtext-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/erikw/nestedtext-ruby/actions/workflows/ci.yml)
[![GitHub Actions: Continuous Deployment](https://github.com/erikw/nestedtext-ruby/actions/workflows/cd.yml/badge.svg)](https://github.com/erikw/nestedtext-ruby/actions/workflows/cd.yml)
[![GitHub Actions: CodeQL Analysis](https://github.com/erikw/nestedtext-ruby/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/erikw/nestedtext-ruby/actions/workflows/codeql-analysis.yml)
[![Code Climate Maintainability](https://api.codeclimate.com/v1/badges/8409b6cdc3dc62a33f6f/maintainability)](https://codeclimate.com/github/erikw/nestedtext-ruby/maintainability)
[![Code Climate Test Coverage](https://api.codeclimate.com/v1/badges/8409b6cdc3dc62a33f6f/test_coverage)](https://codeclimate.com/github/erikw/nestedtext-ruby/test_coverage)
[![SLOC](https://sloc.xyz/github/erikw/nestedtext-ruby?lower=true)](#)
[![License](https://img.shields.io/github/license/erikw/nestedtext-ruby?color=informational)](LICENSE.txt)
[![OSS Lifecycle](https://img.shields.io/osslifecycle/erikw/nestedtext-ruby)](https://github.com/Netflix/osstracker)


A ruby library for the human friendly data format [NestedText](https://nestedtext.org/).

<!-- Use URL to hosted image, so that it shows up at rubydocs.info as well. Using relative image and yardoc option "--asset img:img" did not work. -->
<a href="#" ><img src="https://raw.githubusercontent.com/erikw/nestedtext-ruby/main/img/logo.webp" align="right" width="420px" alt="nestedtext-ruby logo" /></a>

Provided is support for decoding a NestedText file or string to Ruby data structures, as well as encoding Ruby objects to a NestedText file or string. Furthermore there is support for serialization and deserialization of custom classes. The supported language version of the data format can be seen in the badge above. This implementation pass all the [official tests](https://github.com/KenKundert/nestedtext_tests).

This library is inspired by Ruby's stdlib modules `JSON` and `YAML` as well as the Python [reference implementation](https://github.com/KenKundert/nestedtext) of NestedText. Parsing is done with a LL(1) recursive descent parser and dumping with a recursive DFS traversal of the object references.

To make this library practically useful, you should pair it with a [schema validator](#schema).

# What is NestedText?
Citing from the official [introduction](https://nestedtext.org/en/latest/index.html) page:
> NestedText is a file format for holding structured data to be entered, edited, or viewed by people. It organizes the data into a nested collection of dictionaries, lists, and strings without the need for quoting or escaping. A unique feature of this file format is that it only supports one scalar type: strings.  While the decision to eschew integer, real, date, etc. types may seem counter intuitive, it leads to simpler data files and applications that are more robust.
>
> NestedText is convenient for configuration files, address books, account information, and the like. Because there is no need for quoting or escaping, it is particularly nice for holding code fragments.

*"Why do we need another data format?"* is the right question to ask. The answer is that the current popular formats (JSON, YAML, TOML, INI etc.) all have shortcomings which NestedText [addresses](https://nestedtext.org/en/latest/alternatives.html).

## Example
Here's a full-fledged example of an address book (from the official docs):
```nestedtext
# Contact information for our officers

president:
    name: Katheryn McDaniel
    address:
        > 138 Almond Street
        > Topeka, Kansas 20697
    phone:
        cell: 1-210-555-5297
        home: 1-210-555-8470
            # Katheryn prefers that we always call her on her cell phone.
    email: KateMcD@aol.com
    additional roles:
        - board member

vice president:
    name: Margaret Hodge
    ...
```

See the [language introduction](https://nestedtext.org/en/latest/basic_syntax.html) for more details.

# Usage
The **full API documentation** can be found at [rubydocs.info](https://www.rubydoc.info/gems/nestedtext/NestedText). A minimal & fully working example of a project using this library can be found at [erikw/nestedtext-ruby-test](https://github.com/erikw/nestedtext-ruby-test).

## Decoding (reading NT)
This is how you can decode NestedText from a string or directly from a file (`*.nt`) to Ruby object instances:

### Any Top Level Type
```ruby
require 'nestedtext'

ntstr = "- objitem1\n- list item 2"
obj1 = NestedText::load(ntstr)

obj2 = NestedText::load_file("path/to/data.nt")
```

The type of the returned object depends on the top level type in the NestedText data and will be of corresponding native Ruby type. In the example above, `obj1` will be an `Array` and `obj2` will be `Hash` if `data.nt` looks like e.g.

```
key1: value1
key2: value2
```

Thus you must know what you're parsing, or test what you decoded after.

### Explicit Top Level Type
If you already know what you expect to have, you can guarantee that this is what you will get by telling either function what the expected top type is. If not, an error will be raised.

```ruby
require 'nestedtext'

ntstr = "- objitem1\n- list item 2"
array = NestedText::load(ntstr, top_class: Array)

hash = NestedText::load_file("path/to/data.nt", top_class: Hash)

# will raise NestedText::Error as we specify top level String but it will be Array.
NestedText::load(ntstr, top_class: String)
```

## Encoding (writing NT)
This is how you can decode Ruby objects to a NestedText string or file:

```ruby
require 'nestedtext'

data = ["i1", "i2"]

ntstr = NestedText::dump(data)

NestedText::dump_file(data, "path/to/data.nt")
```

### `#to_nt` Convenience
To make it more convenient, the Ruby Core is extended with a `#to_nt` method on the supported types that will dump a String of the data structure. Here's an IRB session showing how it works:

```ruby
irb> require 'nestedtext'
irb> puts "a\nstring".to_nt
> a
> string
irb> puts ["i1", "i2", "i3"].to_nt
- i1
- i2
- i3
irb> hash = {"k1" => "v1",
            "multiline\nkey" => "v2",
            "k3" => ["a", "list"]}
irb> puts hash.to_nt
k1: v1
: multiline
: key
    > v2
k3:
    - a
    - list
```

## Types
Ruby classes maps like this to NestedText types:
Ruby | [NestedText](https://nestedtext.org/en/latest/basic_syntax.html)
---|---
`String`  |`String`
`Array`   |`List`
`Hash`    |`Dictionary`


### Strict Mode
The strict mode determines how classes other than the basic types `String`, `Array` and `Hash` are handled during encoding and decoding. By **default** strict mode is **false**.

With `strict: true`
Ruby | NestedText | Comment
---|---|---
`nil`        |*empty*  | (1.)
`Symbol`     |`String` | Raises `NestedText::Error`
Other Class | --      | Raises `NestedText::Error`


With `strict: false`
Ruby | NestedText | Comment
---|---|---
`nil`        | *Custom Class Encoding* | (1.)
`Symbol`     | `String` |
Custom Class | *Custom Class Encoding* | If the [Custom Class](#custom-classes-serialization) implements `#encode_nt_with`
Other Class | String | `#to_s` will be called if there is no `#encode_nt_with`


* (1.) How empty strings and nil are handled depends on where it is used. This library follows how the official implementation does it.





## Custom Classes Serialization
This library has support for serialization/deserialization of custom classes as well. This is done by letting the objects tell NestedText what data should be used to represent the object instance with the `#encode_nt_with` method (inspired by `YAML`'s `#encode_with` method). All objects being recursively referenced from a root object being serialized must either implement this method or be one of the core supported NestedText data types from the table above.

A class implementing `#encode_nt_with` is referred to as a `Custom Class` in this document.

```ruby
class Apple
  def initialize(type, weight)
    @type = type
    @weight = weight
  end

  def encode_nt_with
    [@type, @weight]
  end
end
```

When an apple instance will be serialized e.g. by `apple.to_nt`, NestedText will call `Apple.encode_nt_with` if it exist and let the returned data be encoded to represent the instance.


To be able to get this instance back when deserializing the NestedText there must be a class method `Class.nt_create(data)`. When deserializing NestedText and the class `Apple` is detected, and the method `#nt_create` exist on the class, it will be called with the decoded data belonging to it. This method should create and return a new instance of the class. In the most simple case it's just translating this to a call to `#new`.

In full, the `Apple` class should look like:

```ruby
class Apple
  def self.nt_create(data)
    new(*data)
  end

  def initialize(type, weight)
    @type = type
    @weight = weight
  end

  def encode_nt_with
    [@type, @weight]
  end
end
```

An instance of this class would be encoded like this:

```ruby
irb> puts NestedText::dump(Apple.new("granny smith", 12))
__nestedtext_class__: Apple
data:
    - granny smith
    - 12
```

If you want to add some more super powers to your custom class, you can add the `#to_nt` shortcut by including the `ToNTMixin`:
```ruby
class Apple
  include NestedText::ToNTMixin
  ...
end

Apple.new("granny smith", 12).to_nt
```


**Important notes**:
* The special key to denote the class name is subject to change in future versions and you **must not** rely on it.
* Custom Classes **can not be a key** in a Hash. Trying to do this will raise an Error.
* When deserializing a custom class, this custom class must be available when calling the `#dump*` methods e.g.
  ```ruby
  require 'nestedtext'
  require_relative 'apple'  # This is needed if Apple is defined in apple.rb and not in this scope already.

  NestedText::load_file('path/to/apple_dump.nt')
  ```

See [encode_custom_classes_test.rb](test/nestedtext/encode_custom_classes_test.rb) for more real working examples.

# Schema
The point of NestedText is to not get in to business of supporting ambiguous types. That's why all values are simple strings. Having only simple strings is not useful in practice though. This is why NestedText is intended to be paired with a [Schema Validator](https://nestedtext.org/en/latest/schemas.html)!

A schema validator can:
* assert that the parsed values are of the expected types
* automatically convert them to Ruby class instances like Integer, Float, etc.

The reference implementation in Python [lists](https://nestedtext.org/en/latest/examples.html) a few examples of Python validators. Here below is an example of how this Ruby implementation of NestedText can be paired it with [RSchema](https://github.com/tomdalling/rschema).

## Example with RSchema
The full and working example can be found at [erikw/nestedtext-ruby-test](https://github.com/erikw/nestedtext-ruby-test/blob/main/parse_validate.rb).

Let's say that you have a program that should connect to a few servers. The list of servers should be stored in a configuration file. With NestedText, a `conf.nt` file could look like:
```yaml
-
  name: global-service
  ip: 192.167.1.1
  port: 8080
-
  name: aux-service
  ip: 17.245.14.2
  port: 67
  # Unstable server, don't use this
  stable: false
```

After parsing this file with this NestedText library, the values for all keys will be string. But to make practical use of this, we would of course like the values for the `port` keys to be `Integer`, and `stable` should have a value of either `true` or `false`. RSchema can do this conversion for us!


```ruby
# Define schema for our list of servers
schema = RSchema.define do
  array(
    hash(
      'name' => _String,
      'ip' => _String,
      'port' => _Integer,
      optional('stable') => boolean
    )
  )
end

# The coercer will automatially convert types
coercer = RSchema::CoercionWrapper::RACK_PARAMS.wrap(schema)

# Parse config file with NestedText
data = NestedText.load_file('conf.nt')

# Validate
result = coercer.validate(data)
raise result.error.to_s unless result.valid?

# Now we have validated data of the right type specified in the schema!
servers = result.value

# Let's use the values for something in our app
stable_servers = servers.select { |server| server['stable'] }
# Not a meaningful sum - just demonstrating that 'port' values are integers and not strings anymore!
port_sum = servers.map { |server| server['port'] }.sum
```

# Installation
1. Add this gem to your ruby project's Gemfile
   - Simply with `$ bundle add nestedtext` when standing inside your project
   - Or manually by adding to `Gemfile`
   ```ruby
     gem 'nestedtext'
   ```
   and then running `$ bundle install`.
1. Require the library and start using it!
   ```ruby
     require 'nestedtext'

     NestedText::load(...)
     NestedText::dump(...)
     obj.to_nt
   ```



# Development
1. Clone the repo
   ```shell
   git clone https://github.com/erikw/nestedtext-ruby.git && cd $(basename "$_" .git)
   ```
1. Install a supported ruby version (see .gemspec) with a ruby version manager e.g. [rbenv](https://github.com/rbenv/rbenv), [asdf](http://asdf-vm.com/) or [RVM](https://rvm.io/rvm/install)
1. run `$ scripts/setup` or `$ bundle install` to install dependencies
1. run `$ scripts/test` or `bundle exec rake test` to run the tests
1. You can also run `$ scripts/console` for an interactive prompt that will allow you to experiment.
1. For local testing, install the gem on local machine with: `$ bundle exec rake install`.
   * or manually with `$ gem build *.gemscpec && gem install *.gem`
1. Watch changes on file system and execute tests with `$ bundle exec guard`.


Extra:
* Make sure that only intended constants and methods are exposed publicly from the module `NestedText`. Check with
   ```
   irb> require 'nestedtext'
   irb> NestedText.constants
   irb> NestedText.methods(false)
   ```
* To see undocumented methods with [YARD](https://www.rubydoc.info/gems/yard/file/docs/GettingStarted.md): `$ yard stats --list-undoc`

# Releasing
Instructions for releasing on rubygems.org below. Optionally make a GitHub [release](https://github.com/erikw/nestedtext-ruby/releases) after this for the pushed git tag.

## (manually) Using bundler/gem_tasks rake tasks
Following instructions from [bundler.io](https://bundler.io/guides/creating_gem.html#releasing-the-gem):
```shell
vi -p lib/nestedtext/version.rb CHANGELOG.md
bundle exec rake build
ver=$(ruby -r ./lib/nestedtext/version.rb -e 'puts NestedText::VERSION')
bundle exec rake release
```

## (semi-manually) Using gem-release gem extension
Using [gem-release](https://github.com/svenfuchs/gem-release):
```shell
vi CHANGELOG.md && git commit -am "Update CHANGELOG.md" && git push
gem bump --version minor --tag --sign --push --release
```
For `--version`, use `major|minor|patch` as needed.

## (semi-automatic, preferred) Using GitHub Actions CD
Just push a new semver tag and the workflow [cd.yml](.github/workflows/cd.yml) will publish a new release at rubygems.org.

```shell
vi -p lib/nestedtext/version.rb CHANGELOG.md
git commit -am "Prepare vX.Y.Z" && git push
git tag vX.Y.Z && git push --tags
```

or **preferred** combined with gem-release:
```shell
vi CHANGELOG.md
git commit -am "Update CHANGELOG.md" && git push
gem bump --version minor --tag --push --sign
```

then watch progress with [gh](https://cli.github.com/)
```shell
gh run watch
```


# Contributing
Bug reports and pull requests are welcome on GitHub at [erikw/nestedtext-ruby](https://github.com/erikw/nestedtext-ruby).

# License
The gem is available as open source with the [License](./LICENSE.txt).

# Acknowledgments
* Thanks to the data format authors making it easier making new implementations by providing an [official test suite](https://github.com/KenKundert/nestedtext_tests).
* Thanks to [pixteller](https://pixteller.com/) & [mp4.to](https://mp4.to/webp/) for offering the tools needed for creating an animated logo.
