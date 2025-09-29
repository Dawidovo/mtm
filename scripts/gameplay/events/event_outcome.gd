extends Resource
class_name EventOutcome

@export var outcome_description: String
@export var base_probability: float = 0.5  # 0.0 to 1.0

# Modifiers
@export var reputation_modifier: float = 0.0  # -0.2 to +0.2
@export var skill_check: String = ""  # e.g., "negotiation", "charm"
@export var skill_check_bonus: float = 0.0

# Immediate effects
@export var money_change: int = 0
@export var reputation_change: float = 0.0
@export var client_satisfaction_change: float = 0.0

# Relationship changes (dictionary of npc_id: change_value)
var relationship_changes: Dictionary = {}

# Delayed effects
@export var trigger_events: Array = []  # Array of event_ids to trigger later
@export var unlock_opportunities: Array = []
@export var add_flags: Array = []
@export var remove_flags: Array = []

func calculate_probability(game_state) -> float:
	var prob = base_probability
	
	# Add reputation modifier
	var rep = game_state.agency.reputation.overall / 100.0
	prob += reputation_modifier * rep
	
	# Add skill check bonus if applicable
	if skill_check != "" and game_state.agency.has(skill_check):
		var skill_value = game_state.agency.get(skill_check)
		prob += (skill_value / 10.0) * skill_check_bonus
	
	# Random factor
	prob += (randf() * 0.2) - 0.1  # -10% to +10%
	
	return clamp(prob, 0.0, 1.0)

func apply(game_state):
	var result = {
		"description": outcome_description,
		"effects": []
	}
	
	# Apply money change
	if money_change != 0:
		game_state.agency.financials.cash += money_change
		result.effects.append({
			"type": "money",
			"value": money_change
		})
	
	# Apply reputation change
	if reputation_change != 0:
		game_state.agency.reputation.overall += reputation_change
		game_state.agency.reputation.overall = clamp(game_state.agency.reputation.overall, 0, 100)
		result.effects.append({
			"type": "reputation",
			"value": reputation_change
		})
	
	# Apply client satisfaction change
	if client_satisfaction_change != 0 and game_state.current_event_client:
		game_state.current_event_client.contract.satisfaction += client_satisfaction_change
		result.effects.append({
			"type": "client_satisfaction",
			"value": client_satisfaction_change
		})
	
	# Apply relationship changes
	for npc_id in relationship_changes:
		if game_state.relationships.has(npc_id):
			game_state.relationships[npc_id] += relationship_changes[npc_id]
			result.effects.append({
				"type": "relationship",
				"npc": npc_id,
				"value": relationship_changes[npc_id]
			})
	
	# Schedule delayed events
	for event_id in trigger_events:
		game_state.event_queue.append(event_id)
	
	# Add flags
	for flag in add_flags:
		if not game_state.world_state.global_flags.has(flag):
			game_state.world_state.global_flags.append(flag)
	
	# Remove flags
	for flag in remove_flags:
		game_state.world_state.global_flags.erase(flag)
	
	return result
