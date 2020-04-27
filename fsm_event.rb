class FsmEvent
	attr_reader :event
	attr_reader :data

	def initialize(event=nil, data=nil)
		@event=event
		@data=data
	end
end