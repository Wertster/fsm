require_relative 'fsm_action_handler'

class DoCallRinging < FsmActionHandler
	def call(args=nil)
		#Call the ancestor generic method first for logging
		super 
		#Now customise the behaviour
		@log.info("DEVICE-CONTROL::INBOUND CALL FROM (#{args}) PLAY RINGING AUDIO THROUGH SPEAKER")
	end
end