require_relative 'fsm_action_handler'

class DoNextCall < FsmActionHandler
	def call(args=nil)
		#Call the ancestor generic method first for logging
		super 
		#Now customise the behaviour
		@log.info("DEVICE-CONTROL::TERMINATE CALL SESSION AND PLAY DIAL-TONE")
	end
end