require_relative 'fsm_action_handler'

class DoLiftHandset < FsmActionHandler
	def call(args=nil)
		#Call the ancestor generic method first for logging
		super 
		#Now customise the behaviour
		@log.info("DEVICE-CONTROL::INITIATING KEYPAD AND PLAYING DIALTONE")
	end
end