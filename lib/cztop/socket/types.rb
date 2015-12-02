module CZTop
  class Socket
    #  Socket types
    module Types
      PAIR = 0
      PUB = 1
      SUB = 2
      REQ = 3
      REP = 4
      DEALER = 5
      ROUTER = 6
      PULL = 7
      PUSH = 8
      XPUB = 9
      XSUB = 10
      STREAM = 11
      SERVER = 12
      CLIENT = 13
    end

    TypeNames = Hash[
      Types.constants.map { |name| i = Types.const_get(name); [ i, name ] }
    ].freeze

    # @param type [Symbol, Integer] type from {Types} or like +:PUB+
    # @return [REQ, REP, PUSH, PULL, ... ] the new socket
    # @see Types
    def self.new_by_type(type)
      case type
      when Integer
        type_code = type
        type_name = TypeNames[type_code] or
          raise ArgumentError, "invalid type %p" % type
        type_class = Socket.const_get(type_name)
      when Symbol
        type_code = Types.const_get(type)
        type_class = Socket.const_get(type)
      else
        raise ArgumentError, "invalid socket type: %p" % type
      end
      ffi_delegate = CZMQ::FFI::Zsock.new(type_code)
      sock = type_class.allocate
      sock.attach_ffi_delegate(ffi_delegate)
      sock
    end

    # Client socket for the ZeroMQ Client-Server Pattern.
    # @see http://rfc.zeromq.org/spec:41
    class CLIENT < Socket
      # @param endpoints [String] endpoints
      def initialize(endpoints)
        attach_ffi_delegate(CZMQ::FFI::Zsock.new_client(endpoints))
      end
    end

    # Server socket for the ZeroMQ Client-Server Pattern.
    # @see http://rfc.zeromq.org/spec:41
    class SERVER < Socket
      # @param endpoints [String] endpoints
      def initialize(endpoints)
        attach_ffi_delegate(CZMQ::FFI::Zsock.new_server(endpoints))
      end
    end

    # Request socket for the ZeroMQ Request-Reply Pattern.
    # @see http://rfc.zeromq.org/spec:28
    class REQ < Socket
      # @param endpoints [String] endpoints
      def initialize(endpoints)
        attach_ffi_delegate(CZMQ::FFI::Zsock.new_req(endpoints))
      end
    end

    # Reply socket for the ZeroMQ Request-Reply Pattern.
    # @see http://rfc.zeromq.org/spec:28
    class REP < Socket
      # @param endpoints [String] endpoints
      def initialize(endpoints)
        attach_ffi_delegate(CZMQ::FFI::Zsock.new_rep(endpoints))
      end
    end

    # Publish socket for the ZeroMQ Publish-Subscribe Pattern.
    # @see http://rfc.zeromq.org/spec:29
    class PUB < Socket
      # @param endpoints [String] endpoints
      def initialize(endpoints)
        attach_ffi_delegate(CZMQ::FFI::Zsock.new_pub(endpoints))
      end
    end

    # Subscribe socket for the ZeroMQ Publish-Subscribe Pattern.
    # @see http://rfc.zeromq.org/spec:29
    class SUB < Socket
      # @param endpoints [String] endpoints
      # @param subscription [String] what to subscribe to
      def initialize(endpoints, subscription=nil)
        attach_ffi_delegate(CZMQ::FFI::Zsock.new_sub(endpoints))
      end
    end

    # Extended publish socket for the ZeroMQ Publish-Subscribe Pattern.
    # @see http://rfc.zeromq.org/spec:29
    class XPUB < Socket
      # @param endpoints [String] endpoints
      def initialize(endpoints)
        attach_ffi_delegate(CZMQ::FFI::Zsock.new_xpub(endpoints))
      end
    end

    # Extended subscribe socket for the ZeroMQ Publish-Subscribe Pattern.
    # @see http://rfc.zeromq.org/spec:29
    class XSUB < Socket
      # @param endpoints [String] endpoints
      def initialize(endpoints)
        attach_ffi_delegate(CZMQ::FFI::Zsock.new_xsub(endpoints))
      end
    end

    # Push socket for the ZeroMQ Pipeline Pattern.
    # @see http://rfc.zeromq.org/spec:30
    class PUSH < Socket
      # @param endpoints [String] endpoints
      def initialize(endpoints)
        attach_ffi_delegate(CZMQ::FFI::Zsock.new_push(endpoints))
      end
    end

    # Pull socket for the ZeroMQ Pipeline Pattern.
    # @see http://rfc.zeromq.org/spec:30
    class PULL < Socket
      # @param endpoints [String] endpoints
      def initialize(endpoints)
        attach_ffi_delegate(CZMQ::FFI::Zsock.new_pull(endpoints))
      end
    end

    # Pair socket for inter-thread communication.
    # @see http://rfc.zeromq.org/spec:31
    class PAIR < Socket
      # @param endpoints [String] endpoints
      def initialize(endpoints)
        attach_ffi_delegate(CZMQ::FFI::Zsock.new_pair(endpoints))
      end
    end

    # Stream socket for the native pattern over. This is useful when
    # communicating with a non-ZMQ peer, done over TCP.
    # @see http://api.zeromq.org/4-2:zmq-socket#toc16
    class STREAM < Socket
      # @param endpoints [String] endpoints
      def initialize(endpoints)
        attach_ffi_delegate(CZMQ::FFI::Zsock.new_stream(endpoints))
      end
    end
  end
end