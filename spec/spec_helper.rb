require 'rubygems'
$:.unshift File.expand_path('../../lib', __FILE__)

if p = ENV['ASIR_LIB_PATH']
  $:.unshift File.expand_path(p)
else
  gem 'asir'
end
require 'asir'

module ASIR
  module Test
    class TestError < ::Exception; end
    class TestObject
      include ASIR::Client
      attr_accessor :spec, :arg, :cls, :msg, :transport, :message
      def initialize spec
        @spec = spec
      end

      def get_data!
        @transport = ASIR::Transport.current
        @message = @transport && @transport.message
      end

      def return_argument arg
        get_data!
        @arg = arg
        arg
      end

      def raise_exception! cls, msg
        get_data!
        @cls = cls
        @msg = msg
        raise cls, msg
      end
    end
  end
end

