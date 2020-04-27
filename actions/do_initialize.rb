require_relative './fsm_action_handler'

class DoInitialize < FsmActionHandler	
	def call(args=nil)
		#Call the ancestor generic method first for logging
		super 
		#Now customise the behaviour
		fsm_raise(:ev_ready)
	end
end