#!/bin/sh
set -x
dir="$(cd "$(dirname $0)" && /bin/pwd)"
PATH="$dir/../bin:$PATH"
export RUBYLIB="$dir/../example:$dir/../lib"
asir="asir verbose=9 config_rb=$dir/config/asir_config.rb" 
args="$*"
args="${args:-ALL}"
# set -e

#############################

case "$args"
in
  *zmq*|*ALL*)

$asir start zmq worker
sleep 1
$asir pid zmq worker
if $asir alive zmq worker; then
  echo "alive"
fi

ruby "$dir/asir_control_client_zmq.rb"
sleep 1

$asir stop zmq worker
sleep 1
$asir pid zmq worker

;;
esac

#############################

exit 0
