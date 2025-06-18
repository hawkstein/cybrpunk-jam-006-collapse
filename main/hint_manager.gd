extends Node

var hints:Dictionary[StringName, Hint] = {}
var queue:Array[QueueItem] = []

class Hint:
	var label := ""
	var shown := false
	func _init(p_label:String):
		label = p_label

class QueueItem:
	var key:StringName
	var target:Node2D
	func _init(p_key:StringName, p_target:Node2D):
		key = p_key
		target = p_target

func _ready() -> void:
	hints.set(&"target_server", Hint.new("Make your way to the target server"))
	hints.set(&"target_server_reminder", Hint.new("Make your way to the target server"))
	hints.set(&"enemy_guard", Hint.new("Avoid the guard program as it moves around"))
	hints.set(&"hack_move", Hint.new("It takes time to hack into each server"))
	hints.set(&"how_to", Hint.new("Use [left/right] keys to choose a target and hit [up] to hack"))
	hints.set(&"runner", Hint.new("You are a runner. Hacking into the servers of the rich corporations"))
	hints.set(&"overclock", Hint.new("Hit [D] to overclock. This speeds up hacking until you overheat"))
	hints.set(&"cooling", Hint.new("When not overclocking, you will slowly cool down"))

func queue_hint(p_key:StringName, p_target:Node2D) -> void:
	var hint = hints.get(p_key)
	if hint and not hint.shown:
		hint.shown = true
		queue.append(QueueItem.new(p_key, p_target))

func pop_hint() -> Variant:
	var item = queue.pop_front()
	if item:
		var label = hints.get(item.key).label
		return { "label": label, "target": item.target }
	else:
		return null

func has_hints() -> bool:
	return queue.size() > 0

func has_shown_hint(p_key:StringName) -> bool:
	return hints.has(p_key) and hints.get(p_key).shown
