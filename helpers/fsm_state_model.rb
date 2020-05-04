require 'logger'
require 'json'

class FsmStateModel
  attr_reader :model_file
  attr_reader :rules
  attr_reader :states
  attr_reader :events
  attr_reader :actions

  DEFAULT_RULES_JSON = File.expand_path(File.join(File.dirname(__FILE__), '..', 'resources', 'state_model.json'))


  def initialize(s_file=DEFAULT_RULES_JSON)
    @log=Logger.new(STDOUT)
    @rules={}
    @states=[]
    @events=[]
    @actions=[]
    @rules=load_rules(s_file)
    check_rules
  end


  private


  def load_rules(s_file)
    @model_file=(s_file||DEFAULT_RULES_JSON)
    return JSON.load(File.open(@model_file, 'r'))
  end


  def check_rules
    #Extract and validate dimensions of the model
    @states=@rules.keys
    @rules.each_pair do |state, val|
      val.each_pair do |event, val| 
        @events << event
        @actions << val['action'] unless @actions.include?(val['action'])
        @states << val['nx_state'] unless @states.include?(val['nx_state'])
      end
    end
  end
end
