require_relative './fsm_action_handler'

class DoTone < FsmActionHandler
	def call(args=nil)
		#Call the ancestor generic method first for logging
		super 
		#Now customise the behaviour
		@log.info("DEVICE-CONTROL::PLAY DTMF TONE - (ToneID=#{args})")
	end
end