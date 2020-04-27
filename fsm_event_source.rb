require 'yaml'
require 'socket'

require_relative 'fsm_const'
require_relative 'fsm_event'

#Utility mixin, with event handling methods
module FsmEventSource

	#Include constants into this module namespace
	include FsmConst
	
	#Establshes binding to a datagram socket on localhost
	def fsm_listen
		@socket ||= UDPSocket.new
		@socket.bind(IP_ADDR, UDP_PORT)
	end

	#Take an event identifier and data/message, instantiate and serialise event object to send
	def fsm_raise(event, data=nil)
		@socket ||= UDPSocket.new
		evt=FsmEvent.new(event.to_sym, data)
		yml=YAML.dump(evt)
		@socket.send(yml, 0, IP_ADDR, UDP_PORT)
	end

	#Read and parse an event off the socket and parse YAML into object
	def fsm_read
		fsm_listen if @socket.nil? 
		raw=@socket.recvfrom(1024)
		raw_msg=raw.first
		evt=YAML.load(raw_msg)
		return evt
	end

end