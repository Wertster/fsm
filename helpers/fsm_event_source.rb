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
		#Instantiate socket object if not already an instance variable
		@socket ||= UDPSocket.new
		#Instntiate event object with the event and data
		evt = FsmEvent.new(event, data)
		#Serialise event object to YAML for transport
		yml = YAML.dump(evt)
		#Send it...
		@socket.send(yml, 0, IP_ADDR, UDP_PORT)
	end

	#Read and parse an event off the socket and parse YAML into object
	def fsm_read
		#Blocking listen on the socket it not already listening
		fsm_listen if @socket.nil? 
		#Pull the next message from the inbound socket
		raw = @socket.recvfrom(1024)
		#Extract the first segment from the message object
		raw_msg = raw.first
		#De-serialise back into Event object
		evt=YAML.load(raw_msg)
		#Return it
		return evt
	end

end