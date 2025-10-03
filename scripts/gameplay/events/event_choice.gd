extends Resource
class_name EventChoice

@export var choice_id: String
@export var label: String
@export var description: String

# Requirements to show this choice
@export var required_money: int = 0
@export var required_reputation: float = 0.0
@export var required_skills: Dictionary = {}

# Possible outcomes
var outcomes: Array = []  # Array of EventOutcome

func is_available(game_state) -> bool:
	if game_state.agency.financials.cash < required_money:
		return false
	
	if game_state.agency.reputation.overall < required_reputation:
		return false
	
	# Check skill requirements
	for skill in required_skills:
		if not game_state.agency.has(skill):
			return false
		if game_state.agency.get(skill) < required_skills[skill]:
			return false
	
	return true

func execute(game_state):
	# Calculate which outcome occurs based on probabilities
	var total_weight = 0.0
	for outcome in outcomes:
		total_weight += outcome.calculate_probability(game_state)
	
	var roll = randf() * total_weight
	var accumulated = 0.0
	
	for outcome in outcomes:
		accumulated += outcome.calculate_probability(game_state)
		if roll <= accumulated:
			return outcome.apply(game_state)
	
	# Fallback to first outcome
	return outcomes[0].apply(game_state) if outcomes.size() > 0 else null
