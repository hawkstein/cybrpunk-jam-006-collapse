class_name Connection
extends Node2D
@onready var line_2d: Line2D = $Line2D

var parent:int
var child:int
var idx:int

func draw_to(pos:Vector2) -> void:
	line_2d.add_point(Vector2(0,0))
	line_2d.add_point(to_local(pos))
