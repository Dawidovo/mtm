extends Node
class_name EventManager

# Signals for UI to hook into
signal event_triggered(event)
signal event_completed(event, result)
signal choice_selected(choice)

# Event registry - all available events
var available_events: Dictionary = {}

# Active event tracking
var current_event: BaseEvent = null
var event_history: Array = []
var event_cooldowns: Dictionary = {}

# References
var game_state = null

func _ready():
	randomize()
	_register_all_events()

func initialize(game_state_ref):
	game_state = game_state_ref
	print("EventManager initialized")

func _register_all_events():
	# Register all party events
	_register_event(PremiereEscalationEvent.new())
	_register_event(WeinsteinDinnerEvent.new())
	_register_event(VegasWeddingEvent.new())
	_register_event(AfterShowPartyEvent.new())
	_register_event(VillaPartyEvent.new())
	
	# Add more events as you create them
	# _register_event(DrugBustEvent.new())
	# _register_event(SexTapeLeakEvent.new())
	# etc.
	
	print("Registered %d events" % available_events.size())

func _register_event(event: BaseEvent):
	available_events[event.event_id] = event
	print("Registered event: %s" % event.event_id)

# Called each game month to potentially trigger random events
func process_monthly_events() -> void:
	if current_event != null:
		print("Event already active, skipping")
		return
	
	# Base 40% chance for any event
	if randf() > 0.4:
		return
	
	var eligible_events = _get_eligible_events()
	
	if eligible_events.empty():
		print("No eligible events available")
		return
	
	# Weighted random selection
	var selected_event = _weighted_random_selection(eligible_events)
	
	if selected_event:
		trigger_event(selected_event.event_id)

func _get_eligible_events() -> Array:
	var eligible = []
	
	for event_id in available_events:
		var event = available_events[event_id]
		
		# Check if event can trigger based on game state
		if not event.can_trigger(game_state):
			continue
		
		# Check cooldown
		if event_cooldowns.has(event_id):
			var months_since = game_state.world_state.current_date.month - event_cooldowns[event_id]
			if months_since < event.cooldown_months:
				continue
		
		# Check if can repeat
		if not event.can_repeat and event_history.has(event_id):
			continue
		
		eligible.append(event)
	
	return eligible

func _weighted_random_selection(events: Array) -> BaseEvent:
	if events.empty():
		return null
	
	var total_weight = 0.0
	for event in events:
		total_weight += event.probability_weight
	
	var roll = randf() * total_weight
	var accumulated = 0.0
	
	for event in events:
		accumulated += event.probability_weight
		if roll <= accumulated:
			return event
	
	return events[0]

# Manually trigger a specific event (for testing or story triggers)
func trigger_event(event_id: String) -> bool:
	if current_event != null:
		push_error("Cannot trigger event - another event is active")
		return false
	
	if not available_events.has(event_id):
		push_error("Event not found: %s" % event_id)
		return false
	
	var event = available_events[event_id]
	
	# Trigger the event
	current_event = event.trigger_event(game_state)
	
	# Record in history
	if not event_history.has(event_id):
		event_history.append(event_id)
	
	# Set cooldown
	event_cooldowns[event_id] = game_state.world_state.current_date.month
	
	print("Event triggered: %s - %s" % [event.event_id, event.title])
	emit_signal("event_triggered", current_event)
	
	return true

# Player selects a choice
func select_choice(choice_index: int):
	if current_event == null:
		push_error("No active event")
		return
	
	if choice_index < 0 or choice_index >= current_event.choices.size():
		push_error("Invalid choice index: %d" % choice_index)
		return
	
	var choice = current_event.choices[choice_index]
	
	# Check if choice is available
	if not choice.is_available(game_state):
		push_error("Choice not available: %s" % choice.label)
		return
	
	emit_signal("choice_selected", choice)
	
	# Execute the choice and get result
	var result = choice.execute(game_state)
	
	print("Choice executed: %s" % choice.label)
	print("Outcome: %s" % result.description)
	
	# Complete the event
	_complete_event(result)

func _complete_event(result):
	emit_signal("event_completed", current_event, result)
	current_event = null

# Get formatted event description with all variables replaced
func get_event_description() -> String:
	if current_event == null:
		return ""
	return current_event.get_formatted_description()

# Get all choices for current event
func get_choices() -> Array:
	if current_event == null:
		return []
	return current_event.choices

# Check if a choice is available to the player
func is_choice_available(choice_index: int) -> bool:
	if current_event == null:
		return false
	
	if choice_index < 0 or choice_index >= current_event.choices.size():
		return false
	
	return current_event.choices[choice_index].is_available(game_state)

# Get the reason why a choice is unavailable
func get_choice_unavailable_reason(choice_index: int) -> String:
	if not is_choice_available(choice_index):
		var choice = current_event.choices[choice_index]
		
		if game_state.agency.financials.cash < choice.required_money:
			return "Not enough money (need $%d)" % choice.required_money
		
		if game_state.agency.reputation.overall < choice.required_reputation:
			return "Reputation too low (need %.0f)" % choice.required_reputation
		
		for skill in choice.required_skills:
			if not game_state.agency.has(skill):
				return "Missing skill: %s" % skill
			if game_state.agency.get(skill) < choice.required_skills[skill]:
				return "Skill too low: %s (need %d)" % [skill, choice.required_skills[skill]]
	
	return ""

# Debug: List all available events
func debug_list_events() -> void:
	print("\n=== Available Events ===")
	for event_id in available_events:
		var event = available_events[event_id]
		print("%s: %s (weight: %.1f)" % [event_id, event.title, event.probability_weight])
	print("========================\n")

# Debug: Force trigger event regardless of conditions
func debug_force_event(event_id: String) -> void:
	if not available_events.has(event_id):
		push_error("Event not found: %s" % event_id)
		return
	
	current_event = available_events[event_id].trigger_event(game_state)
	emit_signal("event_triggered", current_event)
	print("DEBUG: Forced event %s" % event_id)

# Get event statistics
func get_stats() -> Dictionary:
	return {
		"total_events": available_events.size(),
		"events_experienced": event_history.size(),
		"current_event": current_event.event_id if current_event else "none",
		"cooldowns_active": event_cooldowns.size()
	}

# Clear history (for new game)
func reset():
	current_event = null
	event_history.clear()
	event_cooldowns.clear()
	print("EventManager reset")

# Save/Load support
func get_save_data() -> Dictionary:
	return {
		"event_history": event_history,
		"event_cooldowns": event_cooldowns,
		"current_event_id": current_event.event_id if current_event else ""
	}

func load_save_data(data: Dictionary) -> void:
	event_history = data.get("event_history", [])
	event_cooldowns = data.get("event_cooldowns", {})
	
	var current_event_id = data.get("current_event_id", "")
	if current_event_id != "" and available_events.has(current_event_id):
		current_event = available_events[current_event_id].trigger_event(game_state)
