# fsm

Ruby implementation of a Finite State Machine for tutorial purposes.

To run this you need ruby 2.5.x, gem and bundler. 

Clone the repo, cd into it, and run `bundle install` to acquire dependencies.

# Running

To run the machine, open a terminal and just cd to the root of the fsm folder and exec:

`ruby fsm_core.rb`

This file is the main finite state machine engine class.

It will bind to a hardwired local socket 6666 for event passing but you can change that in fsm_const.rb

# Testing

To test, open a separate terminal. This will send UDP events into the core for the FSM. To do this cd into the root folder of the fsm project and use:

`ruby fsm_client.rb EVENT_NAME [PARAM]`

For EVENT_NAME you need to provide an event declared in the state model, and for the optional PARAM you can provide any string of data to pass with the event. For example:

`ruby fsm_client.rb ev_initialise`

`ruby fsm_client.rb ev_inbound_call 012345667`

# Caveats

Tab formatting is a little off, and there are no tests as yet. This was put together quickly to demonstrate a tutorial - but can be evolved to a more mature state....time permitting. 
 
