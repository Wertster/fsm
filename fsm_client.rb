require_relative 'fsm_event_source'

include FsmEventSource
puts ARGV.inspect
fsm_raise(ARGV[0].to_sym, ARGV[1])

