extends Resource
class_name BaseEvent

# Core event data
export var event_id: String
export var event_type: String  # party, scandal, business, industry, crisis
export var title: String
export var description: String

# Trigger conditions
export var min_year: int = 1950
export var max_year: int = 2030
export var min_reputation: float = 0.0
export var max_reputation: float = 100.0
export var min_clients: int = 0
export var required_flags: Array = []

# Event weight for random selection
export var probability_weight: float = 1.0
export var can_repeat: bool = false
export var cooldown_months: int = 0

# Available choices
var choices: Array = []  # Array of EventChoice

# Variables that will be injected
var client_name: String = ""
var movie_title: String = ""
var ex_name: String = ""
var producer_name: String = ""

func initialize() -> void:
	# Override in child classes to set up choices
	pass

func can_trigger(game_state) -> bool:
	# Check if event can trigger based on game state
	var current_year = game_state.world_state.current_date.year
	if current_year < min_year or current_year > max_year:
		return false
	
	var reputation = game_state.agency.reputation.overall
	if reputation < min_reputation or reputation > max_reputation:
		return false
	
	if game_state.agency.active_clients.size() < min_clients:
		return false
	
	# Check required flags
	for flag in required_flags:
		if not game_state.world_state.global_flags.has(flag):
			return false
	
	return true

func get_formatted_description() -> String:
	# Replace variables in description
	var formatted = description
	formatted = formatted.replace("{CLIENT_NAME}", client_name)
	formatted = formatted.replace("{MOVIE_TITLE}", movie_title)
	formatted = formatted.replace("{EX_NAME}", ex_name)
	formatted = formatted.replace("{PRODUCER_NAME}", producer_name)
	return formatted

func trigger_event(game_state):
	# Select a random client for this event
	if game_state.agency.active_clients.size() > 0:
		var client = game_state.agency.active_clients[randi() % game_state.agency.active_clients.size()]
		client_name = client.basic_info.first_name + " " + client.basic_info.last_name
		
		# Get movie title if client has recent project
		if client.career.filmography.size() > 0:
			var project_id = client.career.filmography[-1]
			var project = game_state.get_project_by_id(project_id)
			if project:
				movie_title = project.basic_info.title
	
	# Generate random names for NPCs
	ex_name = _generate_random_name()
	producer_name = _generate_random_name()
	
	return self

func _generate_random_name() -> String:
	var first_names = ["Alex", "Jordan", "Morgan", "Casey", "Riley"]
	var last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones"]
	return first_names[randi() % first_names.size()] + " " + last_names[randi() % last_names.size()]
