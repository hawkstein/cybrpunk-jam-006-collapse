extends BTAction

func _tick(_delta: float) -> Status:
	if agent is Guard:
		var options = agent.options
		var idx = randi_range(0, options.keys().size() - 1)
		var	choice = options.keys().get(idx)
		print("previous server: ", blackboard.get_var(&"previous_server"))
		while choice == blackboard.get_var(&"previous_server") and options.keys().size() > 1:
			print("previous server == ", choice)
			idx = randi_range(0, options.keys().size() - 1)
			choice = options.keys().get(idx)
		print("choice :", choice)
		blackboard.set_var(&"previous_server", agent.current_server.id)
		print("previous server set to: ", blackboard.get_var(&"previous_server"))
		agent.request_move_to_server.emit(agent, choice)
		return SUCCESS
	else:
		print("Agent is not a Guard, task cannot run")
		return FAILURE
