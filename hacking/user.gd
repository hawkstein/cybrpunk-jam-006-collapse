extends Sprite2D
@onready var overclock_progress_bar: ProgressBar = $OverclockProgressBar

func update_overclock(percentage:int) -> void:
	overclock_progress_bar.value = percentage
