require_relative 'fsm_action_handler'

class DoTerminateCall < FsmActionHandler
	def call(args=nil)
		#Call the ancestor generic method first for logging
		super 
		#Now customise the behaviour
		@log.info("DEVICE-CONTROL::TERMINATING CALL SETUP")
	end
end