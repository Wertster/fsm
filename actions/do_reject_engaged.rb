require_relative './fsm_action_handler'

class DoRejectEngaged < FsmActionHandler
	def call(args=nil)
		#Call the ancestor generic method first for logging
		super 
		#Now customise the behaviour
		@log.info("DEVICE-CONTROL::REJECT CALL SETUP WITH ENGAGED TONE")
	end
end