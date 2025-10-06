extends Control

@onready var event_manager = $EventManager
@onready var title_label = $VBoxContainer/TitleLabel
@onready var description_label = $VBoxContainer/DescriptionLabel
@onready var choices_container = $VBoxContainer/ChoicesContainer
@onready var result_label = $VBoxContainer/ResultLabel
@onready var trigger_button = $VBoxContainer/ButtonsContainer/TriggerRandomButton
@onready var reset_button = $VBoxContainer/ButtonsContainer/ResetButton

var mock_game_state = null

func _ready():
	# Create mock game state
	_create_mock_game_state()
	
	# Initialize event manager
	event_manager.initialize(mock_game_state)
	
	# Connect signals
	event_manager.event_triggered.connect(_on_event_triggered)
	event_manager.event_completed.connect(_on_event_completed)
	
	# Connect buttons
	trigger_button.pressed.connect(_on_trigger_random_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	
	# Debug: list all events
	event_manager.debug_list_events()
	
	# Show initial state
	_show_idle_state()

func _create_mock_game_state():
	# Create minimal game state for testing
	mock_game_state = {
		"agency": {
			"financials": {
				"cash": 100000
			},
			"reputation": {
				"overall": 50.0
			},
			"active_clients": [
				{
					"basic_info": {
						"first_name": "John",
						"last_name": "Doe"
					},
					"career": {
						"filmography": []
					},
					"contract": {
						"satisfaction": 50.0
					}
				}
			],
			"negotiation": 5,
			"charm": 5
		},
		"world_state": {
			"current_date": {
				"year": 2015,
				"month": 3,
				"day": 15
			},
			"global_flags": []
		},
		"relationships": {},
		"event_queue": [],
		"current_event_client": null
	}
	
	# Set current_event_client
	mock_game_state.current_event_client = mock_game_state.agency.active_clients[0]
	
	# Helper method for game state - fixed parameter name with underscore prefix
	mock_game_state.get_project_by_id = func(_project_id): 
		return {
			"basic_info": {
				"title": "Test Movie"
			}
		}

func _show_idle_state():
	title_label.text = "Movie Talent Manager - Event Test"
	description_label.text = "Click 'Trigger Random Event' to start testing events.\n\nCurrent Status:\nCash: $%d | Reputation: %.1f | Client Satisfaction: %.1f" % [
		mock_game_state.agency.financials.cash,
		mock_game_state.agency.reputation.overall,
		mock_game_state.agency.active_clients[0].contract.satisfaction
	]
	result_label.text = "Waiting for event..."
	
	# Clear choices
	for child in choices_container.get_children():
		child.queue_free()

func _on_event_triggered(event):
	title_label.text = event.title
	description_label.text = event.get_formatted_description()
	
	# Clear previous choices
	for child in choices_container.get_children():
		child.queue_free()
	
	# Create buttons for each choice
	var choices = event_manager.get_choices()
	for i in range(choices.size()):
		var choice = choices[i]
		var button = Button.new()
		button.text = "%s\n%s" % [choice.label, choice.description]
		button.custom_minimum_size = Vector2(0, 100)
		button.pressed.connect(_on_choice_selected.bind(i))
		
		# Style the button
		button.add_theme_font_size_override("font_size", 14)
		
		# Disable if not available
		if not event_manager.is_choice_available(i):
			button.disabled = true
			button.tooltip_text = event_manager.get_choice_unavailable_reason(i)
		
		choices_container.add_child(button)
	
	result_label.text = "Choose your action..."

func _on_choice_selected(choice_index: int):
	event_manager.select_choice(choice_index)

func _on_event_completed(_event, result):
	result_label.text = "=== RESULT ===\n\n"
	result_label.text += result.description + "\n\n"
	
	# Show effects
	if result.has("effects") and result.effects.size() > 0:
		result_label.text += "EFFECTS:\n"
		for effect in result.effects:
			match effect.type:
				"money":
					result_label.text += "  💰 Money: %+d\n" % effect.value
				"reputation":
					result_label.text += "  ⭐ Reputation: %+.1f\n" % effect.value
				"client_satisfaction":
					result_label.text += "  😊 Client Satisfaction: %+.1f\n" % effect.value
	
	result_label.text += "\n=== NEW STATUS ===\n"
	result_label.text += "Cash: $%d\n" % mock_game_state.agency.financials.cash
	result_label.text += "Reputation: %.1f\n" % mock_game_state.agency.reputation.overall
	result_label.text += "Client Satisfaction: %.1f" % mock_game_state.agency.active_clients[0].contract.satisfaction
	
	# Clear choices
	for child in choices_container.get_children():
		child.queue_free()

func _on_trigger_random_pressed():
	event_manager.process_monthly_events()
	
	# If no event triggered, show message
	if event_manager.current_event == null:
		result_label.text = "❌ No event triggered this month!\n\nTry again or check console for details."

func _on_reset_pressed():
	# Reset game state
	mock_game_state.agency.financials.cash = 100000
	mock_game_state.agency.reputation.overall = 50.0
	mock_game_state.agency.active_clients[0].contract.satisfaction = 50.0
	mock_game_state.world_state.global_flags.clear()
	
	# Reset event manager
	event_manager.reset()
	event_manager.initialize(mock_game_state)
	
	_show_idle_state()
	
	print("✓ Game reset!")
