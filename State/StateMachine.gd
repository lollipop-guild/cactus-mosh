extends Node2D

# Need to get owner_node somehow
var owner_node

var current_state
var previous_state
var global_state

func set_current_state(state):
  self.current_state = state

func set_global_state(state):
  self.global_state = state

func set_previous_state(state):
  self.previous_state = state

func update_state():
  if global_state:
    global_state.execute(owner_node)

  if current_state:
    current_state.execute(owner_node)

func change_state(new_state):
  self.previous_state = self.current_state
  self.current_state.exit(owner_node)
  self.current_state = new_state
  self.current_state.enter(owner_node)

func revert_to_previous_state():
  change_state(self.previous_state)

func set_to_previous_state():
  var temp_curr = self.current_state
  set_current_state(self.previous_state)
  self.previous_state = temp_curr

func is_in_state(state):
  return state == self.current_state

func _init(owner_node):
	self.owner_node = owner_node
