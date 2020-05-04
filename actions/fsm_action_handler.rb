require_relative '../helpers/fsm_event_source'

#Base class for all action handlers to inherit
class FsmActionHandler
	include FsmEventSource

	def initialize
		@log||=Logger.new(STDOUT)
		@log.debug("#{self.class} initialized")
	end

	def call(args=nil)
		@log.debug("#{self.class} called")
	end
end