extends Node

# Minimal game state for testing
var game_state = {
	"agency": {
		"financials": {
			"cash": 100000
		},
		"reputation": {
			"overall": 50.0
		},
		"active_clients": [],
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

func _ready():
	# Create a test client
	var test_client = {
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
	game_state.agency.active_clients.append(test_client)
	game_state.current_event_client = test_client
	
	print("GameManager initialized")

# Helper method for game state
func get_project_by_id(project_id):
	return {
		"basic_info": {
			"title": "Test Movie"
		}
	}

func reset_game():
	game_state.agency.financials.cash = 100000
	game_state.agency.reputation.overall = 50.0
	if game_state.agency.active_clients.size() > 0:
		game_state.agency.active_clients[0].contract.satisfaction = 50.0
	game_state.world_state.global_flags.clear()
	print("Game reset")
