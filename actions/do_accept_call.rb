require_relative './fsm_action_handler'

class DoAcceptCall < FsmActionHandler
	def call(args=nil)
		#Call the ancestor generic method first for logging
		super 
		#Now customise the behaviour
		@log.info("DEVICE-CONTROL::ACCEPTING CALL(#{args}), STOP RINGING, DISPLAY CALLER")
	end
end