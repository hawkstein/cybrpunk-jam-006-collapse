extends Node2D

@onready var hsm: LimboHSM = $LimboHSM

var current_server:Server
var options:Dictionary[int, Node2D]
var selection:int

func _ready() -> void:
	_initialise_hsm()

func _initialise_hsm() -> void:
	var select_state := LimboState.new().named("Select")
	var hack_state := LimboState.new().named("Hack")
	var move_state := LimboState.new().named("Move")
	
	hsm.add_child(select_state)
	hsm.add_child(hack_state)
	hsm.add_child(move_state)
	
	hsm.add_transition(select_state, hack_state, &"hack_started")
	hsm.add_transition(hack_state, move_state, &"hack_finished")
	hsm.add_transition(move_state, select_state, &"move_finished")
	
	hsm.initialize(self)
	hsm.initial_state = select_state
	hsm.set_active(true)

func set_current_server(_current_server:Server, _options:Dictionary[int, Node2D]) -> void:
	current_server = _current_server
	options = _options
	selection = options.keys().get(0)
	
