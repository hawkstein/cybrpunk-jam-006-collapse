extends Node

# holds game level info as an auto run

func _ready() -> void:
	SceneManager.process_mode = Node.PROCESS_MODE_ALWAYS
