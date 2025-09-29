extends Control

onready var event_manager = $EventManager
onready var title_label = $VBoxContainer/Title
onready var description_label = $VBoxContainer/Description
onready var choices_container = $VBoxContainer/ChoicesContainer
onready var result_label = $VBoxContainer/ResultLabel

var mock_game_state = null

func _ready():
	_create_mock_game_state()
	event_manager.initialize(mock_game_state)
	
	# Connect signals
	event_manager.connect("event_triggered", self, "_on_event_triggered")
	event_manager.connect("event_completed", self, "_on_event_completed")
	
	# Debug: list all events
	event_manager.debug_list_events()

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
			]
		},
		"world_state": {
			"current_date": {
				"year": 2015,
				"month": 3,
				"day": 15
			},
			"global_flags": []
		},
		"current_event_client": null
	}
	
	# Helper methods for game state
	mock_game_state.get_project_by_id = funcref(self, "_mock_get_project")

func _mock_get_project(project_id):
	return {
		"basic_info": {
			"title": "Test Movie"
		}
	}

func _on_event_triggered(event):
	title_label.text = event.title
	description_label.text = event_manager.get_event_description()
	
	# Clear previous choices
	for child in choices_container.get_children():
		child.queue_free()
	
	# Create buttons for each choice
	var choices = event_manager.get_choices()
	for i in range(choices.size()):
		var choice = choices[i]
		var button = Button.new()
		button.text = "%s\n%s" % [choice.label, choice.description]
		button.connect("pressed", self, "_on_choice_selected", [i])
		
		# Disable if not available
		if not event_manager.is_choice_available(i):
			button.disabled = true
			button.hint_tooltip = event_manager.get_choice_unavailable_reason(i)
		
		choices_container.add_child(button)
	
	result_label.text = ""

func _on_choice_selected(choice_index: int):
	event_manager.select_choice(choice_index)

func _on_event_completed(event, result):
	result_label.text = "Result: %s" % result.description
	
	# Show effects
	for effect in result.effects:
		match effect.type:
			"money":
				result_label.text += "\nMoney: %+d" % effect.value
			"reputation":
				result_label.text += "\nReputation: %+.1f" % effect.value
			"client_satisfaction":
				result_label.text += "\nClient Satisfaction: %+.1f" % effect.value

# Button to trigger random event
func _on_trigger_random_pressed():
	event_manager.process_monthly_events()

# Button to trigger specific event
func _on_trigger_premiere_pressed():
	event_manager.debug_force_event("premiere_escalation")
