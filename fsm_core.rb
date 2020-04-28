require 'logger'
require 'yaml'
require 'socket'
require 'thread'

require_relative 'fsm_const'
require_relative 'fsm_event'
require_relative 'fsm_event_source'

class FsmCore
	include FsmConst
	include FsmEventSource

	RULESET  = {
		# Defined as the starting state by init code
		:st_idle => {
			:ev_initialise => {action: :do_initialize,            nx_state: :st_starting} 
		},
		#After forced startup event, this is the transitional state as the framework is booted
		:st_starting => {
			:ev_ready           => {action: :do_nothing,          nx_state: :st_ready}, 
			:ev_error           => {action: :do_abort,            nx_state: :st_idle} 
		},
		#When all framework is up, we're ready to process events associated with primary function
		:st_ready => {
			:ev_lift_handset    => {action: :do_lift_handset,     nx_state: :st_off_hook},
			:ev_inbound_call    => {action: :do_call_ringing,     nx_state: :st_call_ringing} 
		},
		:st_off_hook => {
			:ev_replace_handset => {action: :do_replace_handset,  nx_state: :st_ready},
			:ev_inbound_call    => {action: :do_reject_engaged,   nx_state: :st_no_change},
			:ev_next_call       => {action: :do_next_call,   	  nx_state: :st_off_hook},
			:ev_keypad          => {action: :do_tone,   		  nx_state: :st_no_change}, 
		},
		:st_call_ringing => {
			:ev_answer_timeout  => {action: :do_terminate_call,   nx_state: :st_ready},
			:ev_lift_handset    => {action: :do_accept_call,      nx_state: :st_call_active},
		},
		:st_call_active => {
			:ev_replace_handset => {action: :do_terminate_call,   nx_state: :st_ready}, 
			:ev_call_dropped    => {action: :do_terminate_call,   nx_state: :st_ready}, 
			:ev_keypad          => {action: :do_tone,   		  nx_state: :st_no_change}, 
			:ev_next_call       => {action: :do_next_call,   	  nx_state: :st_off_hook}, 
		}
	}

	#Accessors/getters for instance vars
	attr_reader :socket
	attr_reader :state
	attr_reader :rules
	attr_reader :states
	attr_reader :events
	attr_reader :actions
	attr_reader :functions

	def initialize
		@socket=nil
		@log=Logger.new(STDOUT)
		@rules={}
		@states=[]
		@events=[]
		@actions=[]
		@functions={}
		#Core objects
		@inbox=Queue.new
		@sema=Mutex.new

		load_rules
	    check_rules
		load_handlers
		fsm_listen

		#ready to do
		@state=:st_idle
		
		#Put socket receiver into background thread
		detatch_event_loop

		#Start the reactor Scottie :-)
		fsm_raise(:ev_initialise)

		#Start the main event processing loop
		while (true)
			if @inbox.empty?
				#Avoid melt-down, its greener
				sleep(0.1)
			else
				do_something
			end
		end
	end


	private


	def do_something
		inevt=nil
		@sema.synchronize{
			#Only mutex-protect the queue
			inevt = @inbox.pop
		}
		handle_event(inevt)
	end

	def detatch_event_loop
		#Sit on the local socket and queue inbound events
		Thread.new {
			while(true)
				evt=fsm_read
				@sema.synchronize{
					@inbox.push(evt)	
				} 
			end
		}
	end

	def handle_event(evt)
		rule   = @rules[@state]||{}
		action = rule[evt.event]||nil
		if action.nil?
			@log.error "event[#{evt.event}] in state[#{@state}] is not supported..."
			return
		end
		#Call the handler class/method for the action 
		@log.debug "state[#{@state}] + event[#{evt.event}] = action[#{action[:action]}] => next[#{action[:nx_state]}]"
		#Call the registered handler class
		execute_action(action[:action], evt.data)
		#Now we have executed the handler there may be 0..n events in transit, so proceed to next state	
		@state = action[:nx_state] unless action[:nx_state].eql?(:st_no_change)
		@log.debug "Now in state [#{@state}]"
	end
 
	def execute_action(action, data=nil)
		start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
		@functions[action].call(data)
		end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  		elapsed_time = (end_time - start_time).round(6)
  		@log.debug("Action [#{action}] executed in [#{elapsed_time.to_s}]msecs")
  		if elapsed_time > 0.25  #quarter of a second
	  		@log.warn("Action [#{action}] in State [#{@state}] exceeds recommended SLA !!")  			
  		end
  	end

	def load_rules
		#This could load from YAML
		@rules=RULESET
	end

	def check_rules
		#Extract and validate dimensions of the model
		@states=@rules.keys
		@rules.each_pair do |state, val|
			val.each_pair do |event, val| 
				@events << event
				@actions << val[:action] unless @actions.include?(val[:action])
				@states << val[:nx_state] unless @states.include?(val[:nx_state])
			end
		end
	end

	def load_handlers
		#Load all of the handlers from the classes subfolder
		@actions.each do |action|
			#Turn the action name (symbol) into a convention based class name - so we can instantiate
			clazz =  action.to_s.split("_").collect(&:capitalize).join
			#Include the class/function definition from a subfolder based on naming convention
			require_relative(File.join('actions', action.to_s))
			#Store an instance of the handler object defined for the action name
			@functions[action] = Object.const_get(clazz).new
		end
	end
end

#Temporary - just instantiate the StateModel class to execute it
phone=FsmCore.new
