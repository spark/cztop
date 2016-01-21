[![Build Status on Travis CI](https://travis-ci.org/paddor/cztop.svg?branch=master)](https://travis-ci.org/paddor/cztop?branch=master)
[![Code Climate](https://codeclimate.com/repos/56677a7849f50a141c001784/badges/48f3cca3c62df9e4b17b/gpa.svg)](https://codeclimate.com/repos/56677a7849f50a141c001784/feed)
[![Inline docs](http://inch-ci.org/github/paddor/cztop.svg?branch=master&style=shields)](http://inch-ci.org/github/paddor/cztop)
[![Dependency Status](https://gemnasium.com/paddor/cztop.svg)](https://gemnasium.com/paddor/cztop)
[![Coverage Status](https://coveralls.io/repos/paddor/cztop/badge.svg?branch=master&service=github)](https://coveralls.io/github/paddor/cztop?branch=master)

# CZTop

```
_________  _____________________
\_   ___ \ \____    /\__    ___/____  ______
/    \  \/   /     /   |    |  /  _ \ \____ \
\     \____ /     /_   |    | (  <_> )|  |_> >
 \______  //_______ \  |____|  \____/ |   __/
        \/         \/                 |__|
```

CZTop is a CZMQ binding for Ruby. It is based on
[czmq-ffi-gen](https://github.com/paddor/czmq-ffi-gen), the generated low-level
FFI binding of [CZMQ](https://github.com/zeromq/czmq) and has a focus on being
easy to use for Rubyists (POLS) and providing first class support for security
mechanisms (like CURVE).

## Reasons

Why another CZMQ Ruby binding? Here is a list of existing projects I found and
the issues with them, from my point of view:

* [Asmod4n/ruby-ffi-czmq](https://github.com/Asmod4n/ruby-ffi-czmq)
  * outdated
  * according to its author, it's an "abomination"
* [methodmissing/rbczmq](https://github.com/methodmissing/rbczmq)
  * no support for security features (see [methodmissing/rbczmq#28](https://github.com/methodmissing/rbczmq/issues/28))
  * no JRuby support (see [methodmissing/rbczmq#48](https://github.com/methodmissing/rbczmq/issues/48))
  * doesn't feel like Ruby
* [mtortonesi/ruby-czmq](https://github.com/mtortonesi/ruby-czmq)
  * no tests
  * outdated
  * doesn't feel like Ruby
* [chuckremes/ffi-rzmq](https://github.com/chuckremes/ffi-rzmq)
  * low level ZMQ gem, not CZMQ

Furthermore, I knew about the generated low-level Ruby FFI binding in the
[zeromq/czmq](https://github.com/zeromq/czmq) repository. I wanted to make use
of it because I love that it's generated (and thus, most likely correct
and up-to-date). Unfortunately, it was in pretty bad shape and missing a few
CZMQ classes.

So I decided to improve the quality and usability of the binding and add the
missing classes. The result is
[czmq-ffi-gen](https://github.com/paddor/czmq-ffi-gen) which provides a solid
foundation for CZTop.

## Goals

Here are some some of the goals I have/had in mind for this library:

- [x] as easy as possible, Ruby-esque API
- [x] first class support for security (CURVE mechanism)
  - [x] including handling of certificates
- [x] support MRI, Rubinius, and JRuby
- [x] high-quality API documentation
- [x] 100% test coverage
- [x] provide a portable Z85 implementation
  * unlike [fpesce/z85](https://github.com/fpesce/z85), which is a C extension
- [ ] use it to replace the [Celluloid::ZMQ](https://github.com/celluloid/celluloid-zmq) part of [Celluloid](https://github.com/celluloid/celluloid)
- [ ] implement some of the missing (CZMQ based) Ruby examples in the [ZMQ Guide](http://zguide.zeromq.org/page:all)

## Overview

### Class Hierarchy

Here's an overview of the core classes:

* CZTop
  * Actor
  * Authentiator < Actor
  * Beacon < Actor
  * Certificate
  * Config
  * Frame
  * Loop
  * Message
  * Monitor < Actor
  * Proxy < Actor
  * Poller
  * Socket
    * REQ < Socket
    * REP < Socket
    * ROUTER < Socket
    * DEALER < Socket
    * PUSH < Socket
    * PULL < Socket
    * PUB < Socket
    * SUB < Socket
    * XPUB < Socket
    * XSUB < Socket
    * PAIR < Socket
    * STREAM < Socket
    * CLIENT < Socket
    * SERVER < Socket
  * Z85
    * Padded < Z85

More information in the [API documentation](http://www.rubydoc.info/github/paddor/cztop).

### Features

* Ruby-like API
  * method names
    * `#x=` methods instead of `#set_x` (e.g. socket options)
    * `#[]` where it makes sense (e.g. on a Message, Config, or Certificate)
  * sending a message via a socket is done with `Socket#<<`
    * `socket << "simple message"`
    * `socket << ["multi", "frame", "message"]`
  * no manual error checking needed
    * if there's an error, an appropriate exception is raised
  * of course, no manual dealing with the ZMQ context
* easy security
  * use `Socket#CURVE_server!(cert)` on the server
  * and `Socket#CURVE_client!(client_cert, server_cert)` on the client
* socket types as Ruby classes
  * no need to manually pass some constant
    * but you can: `CZTop::Socket.new_by_type(:REP)`
  * e.g. `#subscribe` only exists on CZTop::Socket::SUB
* SERVER and CLIENT ready
  * see CZTop::Socket::SERVER and CZTop::Socket::CLIENT
  * there are `#routing_id` and `#routing_id=` on the following classes:
    * CZTop::Message
    * CZTop::Frame
* ZMTP 3.1 heartbeat ready
  * `socket.options.heartbeat_ivl = 2000`
  * `socket.options.heartbeat_timeout = 8000`

## Installation

This gem requires the presence of the CZMQ library, which in turn requires the
ZMQ library. For **security mechanisms** like CURVE, you'll need
ZMQ >= 4.0 and [libsodium](https://github.com/jedisct1/libsodium).

On OSX using homebrew, run:

    $ brew install libsodium
    $ brew install zmq  --with-libsodium
    $ brew install czmq

**Warning**: To make use of the full feature set of CZTop, you'll need need to
install both ZMQ and CZMQ from master, like this:

    $ brew install zmq  --with-libsodium --HEAD
    $ brew install czmq --HEAD

See below for the known issues if you're using the current stable releases.

If you're running Linux, go check [this page](http://zeromq.org/distro:_start)
to get more help. Make sure to install CZMQ, not only ZMQ.

To then use this gem, add this line to your application's Gemfile:

```ruby
gem 'cztop'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cztop

### Known Issues if using the current stable releases

When using ZMQ 4.1/4.0:
* no CLIENT/SERVER sockets. Don't try.

When using ZMQ 3.2:
* no security mechanisms like CURVE. Don't try.
* no CLIENT/SERVER sockets. Don't try.

When using CZMQ 3.0:
* don't use `Certificate#[]=` to unset meta data (by passing `nil`)
  * `zcert_unset_meta()` was added more recently for that case
  * see [zeromq/czmq#1248](https://github.com/zeromq/czmq/pull/1248)
* if you use Beacon, make sure you also call `Beacon#configure`. Otherwise it closes STDIN when being destroyed.
  * see [zeromq/czmq#1281](https://github.com/zeromq/czmq/issues/1281)

### Supported Ruby versions

See [.travis.yml](https://github.com/paddor/cztop/blob/master/.travis.yml) for a list of Ruby versions against which CZTop
is tested.

At the time of writing, these include:

* MRI (2.3, 2.2.4, 2.1.8)
* Rubinius (HEAD)
* JRuby 9000 (HEAD)

## Usage

See the [examples](https://github.com/paddor/cztop/blob/master/examples) directory for some examples. Here's a very simple one:

### rep.rb:

```ruby
#!/usr/bin/env ruby
require_relative '../../lib/cztop'

# create and bind socket
socket = CZTop::Socket::REP.new("ipc:///tmp/req_rep_example")
puts "<<< Socket bound to #{socket.last_endpoint.inspect}"

# Simply echo every message, with every frame String#upcase'd.
while msg = socket.receive
  puts "<<< #{msg.to_a.inspect}"
  socket << msg.to_a.map(&:upcase)
end
```

### req.rb:

```ruby
#!/usr/bin/env ruby
require_relative '../../lib/cztop'

# connect
socket = CZTop::Socket::REQ.new("ipc:///tmp/req_rep_example")
puts ">>> Socket connected."

# simple string
socket << "foobar"
msg = socket.receive
puts ">>> #{msg.to_a.inspect}"

# multi frame message as array
socket << %w[foo bar baz]
msg = socket.receive
puts ">>> #{msg.to_a.inspect}"

# manually instantiating a Message
msg = CZTop::Message.new("bla")
msg << "another frame" # append a frame
socket << msg
msg = socket.receive
puts ">>> #{msg.to_a.inspect}"

##
# This will send 20 additional messages:
#
#   ./req.rb 20
#
if ARGV.first
  ARGV.first.to_i.times do
    socket << ["fooooooooo", "baaaaaar"]
    puts ">>> " + socket.receive.to_a.inspect
  end
end
```

### Running it

```
$ ./rep.rb & ./req.rb 3
[3] 35321
>>> Socket connected.
<<< Socket bound to "ipc:///tmp/req_rep_example"
<<< ["foobar"]
>>> ["FOOBAR"]
<<< ["foo", "bar", "baz"]
>>> ["FOO", "BAR", "BAZ"]
<<< ["bla", "another frame"]
>>> ["BLA", "ANOTHER FRAME"]
<<< ["fooooooooo", "baaaaaar"]
>>> ["FOOOOOOOOO", "BAAAAAAR"]
<<< ["fooooooooo", "baaaaaar"]
>>> ["FOOOOOOOOO", "BAAAAAAR"]
<<< ["fooooooooo", "baaaaaar"]
>>> ["FOOOOOOOOO", "BAAAAAAR"]
$
```

## Documentation

The API should be fairly straight-forward to anyone who is familiar with CZMQ
and Ruby.  The following API documentation is currently available:

* [YARD API documentation](http://www.rubydoc.info/github/paddor/cztop)

Feel free to start a [wiki](https://github.com/paddor/cztop/wiki) page.

## TODO

* [x] pack generated code into its own gem ([czmq-ffi-gen](https://github.com/paddor/czmq-ffi-gen))
* think of a neat Ruby API, including:
  - [x] Actor
  - [x] Beacon
  - [x] Certificate
  - [x] Socket
    - [50%] access to all socket options
    - [x] Security mechanisms
  - [x] Message
  - [x] Frame
    - [x] enumerable Frames
  - [x] Authenticator
  - [x] Loop
  - [x] Monitor
  - [x] Poller
  - [x] Proxy
  - [x] Config
  - [x] Z85
* write the missing XML API files in CZMQ
  - [x] zarmour.xml
  - [x] zconfig.xml
  - [x] zsock_option.xml
  - [x] zcert.xml
  - [x] zcertstore.xml
* [x] check availability of libsodium within CZTop
* [x] read error strings for exceptions where appropriate (zmq_strerror)
* [x] add support for ZMTP 3.1 heartbeats in CZMQ
  * [ ] [zeromq/libzmq#1710](https://github.com/zeromq/libzmq/issues/1710)
* [x] add padded variant of Z85
* add more examples
  * [x] [simple REQ/REP](https://github.com/paddor/cztop/tree/master/examples/simple_req_rep)
  * [x] [Taxy System](https://github.com/paddor/cztop/tree/master/examples/taxi_system) with CURVE security and heartbeating
    * [ ] change from ROUTER/DEALER to SERVER/CLIENT
  * [x] [Actor](https://github.com/paddor/cztop/tree/master/examples/ruby_actor) with Ruby block
  * [ ] PUSH/PULL
  * [ ] PUB/SUB
* [ ] add performance benchmarks
* [ ] support older versions of ZMQ
  * [x] ZMQ HEAD
    * [x] test on CI
  * [x] ZMQ 4.1.4 (untested)
    * [ ] test on CI
  * [x] ZMQ 4.0.5 (untested)
    * [ ] test on CI
  * [x] ZMQ 3.2.5 (untested)
    * [ ] test on CI
* [ ] support older versions of CZMQ
  * [x] CZMQ HEAD
    * [x] test on CI
  * [x] CZMQ 3.0.2
    * no `zcert_meta_unset()` ([zeromq/czmq#1246](https://github.com/zeromq/czmq/issues/1246))
      * [x] adapt czmq-ffi-gen so it doesn't raise while `attach_function`
    * no `zproc`(especially no `zproc_has_curve()`)
      * [x] adapt czmq-ffi-gen so it doesn't raise while `attach_function`, attach `zsys_has_curve()` instead (under same name)
    * [x] adapt test suite to skip affected test examples
    * [ ] test on CI

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/paddor/cztop.

To run the tests before/after you made any changes to the source and have
created a test case for it, use `rake spec`.

## License

The gem is available as open source under the terms of the [ISC License](http://opensource.org/licenses/ISC).
See the [LICENSE](https://github.com/paddor/cztop/blob/master/LICENSE) file.
