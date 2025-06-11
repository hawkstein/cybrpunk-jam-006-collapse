class_name Server
extends Node2D

var id:int
var edges:Array[int]
var connections := Array([], TYPE_OBJECT, "Node2D", null)
var is_target := false

func has_connection(connection_id:int) -> bool:
	return connections.any(func(edge:Connection): return edge.parent == connection_id or edge.child == connection_id)
