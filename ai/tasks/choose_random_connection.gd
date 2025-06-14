extends BTAction

func _tick(_delta: float) -> Status:
	if agent is Guard:
		var options = agent.options
		var idx = randi_range(0, options.keys().size() - 1)
		var	choice = options.keys().get(idx)
		while choice == blackboard.get_var(&"previous_server", null, false) and options.keys().size() > 1:
			idx = randi_range(0, options.keys().size() - 1)
			choice = options.keys().get(idx)
		blackboard.set_var(&"previous_server", agent.current_server.id)
		agent.request_move_to_server.emit(agent, choice)
		return SUCCESS
	else:
		print("Agent is not a Guard, task cannot run")
		return FAILURE
