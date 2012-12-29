# !SLIDE :capture_code_output true
# One-way ZMQ service on alternate queue.

require 'example_helper'
require 'asir/transport/zmq'
begin
  zmq = ASIR::Transport::Zmq.new(:port => 31923,
                                 :encoder => ASIR::Coder::Marshal.new,
                                 :one_way => true,
                                 :queue => 'alternate')
  server_process do
    zmq.prepare_server!
    zmq.run_server!
  end
  UnsafeService.asir.transport = t = zmq
  pr(UnsafeService.asir._configure{ | message, proxy |
       message[:queue] = 'alternate'
     }.do_it(":ok"))
  pr(UnsafeService.asir._configure{ | message, proxy |
       message[:queue] = 'other'
     }.do_it(":other"))
rescue ::Exception => err
  $stderr.puts "### #{$$}: ERROR: #{err.inspect}\n  #{err.backtrace * "\n  "}"
  raise
ensure
  zmq.close rescue nil; sleep 1; server_kill
end

# !SLIDE END
# EXPECT: : client process
# EXPECT: : server process
# EXPECT: UnsafeService.do_it => :ok
# EXPECT: : pr: nil
# EXPECT!: UnsafeService.do_it => :other
# EXPECT!: ERROR
