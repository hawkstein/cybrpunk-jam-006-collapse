class_name Server
extends Node2D

const TRACE = preload("res://hacking/trace.tscn")

@onready var trace_group: Node2D = $Traces
@onready var rack: Sprite2D = $Rack

var id:int
var edges:Array[int]
var connections := Array([], TYPE_OBJECT, "Node2D", null)
var is_target:bool = false:
	set(p_target):
		is_target = p_target
		if is_target:
			rack.modulate.g = 0.2
			rack.modulate.b = 0.2
		else:
			rack.modulate.g = 1
			rack.modulate.b = 1
var enemies := Array([], TYPE_OBJECT, "Node2D", null)
var traces := 0

func has_connection(connection_id:int) -> bool:
	return connections.any(func(edge:Connection): return edge.is_connected_to(connection_id))


func spawn_traces() -> void:
	# add trace nodes to the server trace group node 
	var missing := traces - trace_group.get_child_count()
	if  missing > 0:
		for i in range(missing):
			var t := TRACE.instantiate()
			trace_group.add_child(t)
			t.position = Vector2.from_angle(randf() * TAU) * 30 
	# how should these actually be represented
