extends BTCondition

var found_var := &"found"

func _tick(_delta: float) -> Status:
	var traces = agent.current_server.traces
	var previously_found = blackboard.get_var(found_var, 0, false)
	var found = previously_found + traces
	blackboard.set_var(found_var, found)
	if found > 5:
		return SUCCESS
	else:
		return FAILURE
