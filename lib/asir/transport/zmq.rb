require 'asir/transport/connection_oriented'
gem 'zmq'
require 'zmq'

module ASIR
  class Transport
    # !SLIDE
    # ZeroMQ Transport
    class Zmq < ConnectionOriented
      attr_accessor :queue

      # !SLIDE
      # 0MQ client.
      def _client_connect!
        sock = zmq_context.socket(one_way ? ZMQ::PUB : ZMQ::REQ)
        sock.connect(zmq_uri)
        sock
      rescue ::Exception => exc
        raise exc.class, "#{self.class} #{zmq_uri}: #{exc.message}", exc.backtrace
      end

      # !SLIDE
      # 0MQ server.
      def _server!
        sock = zmq_context.socket(one_way ? ZMQ::SUB : ZMQ::REP)
        sock.setsockopt(ZMQ::SUBSCRIBE, queue) if one_way
        sock.bind("tcp://*:#{port}") # WTF?: why doesn't tcp://localhost:PORT work?
        @server = sock
      rescue ::Exception => exc
        raise exc.class, "#{self.class} #{zmq_uri}: #{exc.message}", exc.backtrace
      end

      def _receive_result state
        return nil if one_way || state.message.one_way
        super
      end

      def _send_result state
        return nil if one_way || state.message.one_way
        super
      end

      def _write payload, stream, state
        if one_way
          q = state && state.message
          q &&= q[:zmq_queue] || q[:queue]
          payload.insert(0, q ? "#{q} " : queue_)
        end
        stream.send payload, 0
        stream
      end

      def _read stream, state
        if data = stream.recv(0) and one_way
          q, data = data.split(/ /, 2)
        end
        data
      end

      def queue
        @queue ||=
          (
          case
          when @uri
            x = URI.parse(@uri).path
          else
            x = ""
          end
          # x << "\t" unless x.empty?
          x.freeze
          )
      end
      def queue_
        @queue_ ||=
          (queue.empty? ? "asir ": queue + " ").freeze
      end

      # server represents a receiving ZMQ endpoint.
      def _server_accept_connection! server
        [ server, @one_way ? nil : server ]
      end

      # ZMQ is message-oriented, process only one message per "connection".
      alias :_server_serve_stream :serve_message!

      def stream_eof? stream
        false
      end

      # Nothing to be closed for ZMQ.
      def _server_close_connection! in_stream, out_stream
        # NOTHING
      end

      def zmq_uri
        @zmq_uri ||=
          (
          u = URI.parse(uri)
          u.path = ''
          u.to_s.freeze
          )
      end

      def zmq_context
        @@zmq_context ||=
          ZMQ::Context.new(1)
      end
      @@zmq_context ||= nil
    end
    # !SLIDE END
  end # class
end # module


