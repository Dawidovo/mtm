extends BaseEvent
class_name AfterShowPartyEvent

func _init():
	event_id = "aftershow_party"
	event_type = "party"
	title = "After-Show Party Decisions"
	description = "It's the biggest night of the year. The awards are over and the after-parties are in full swing. How do you play this?"
	
	min_clients = 1
	min_reputation = 30.0
	probability_weight = 8.0
	can_repeat = true
	cooldown_months = 12
	
	initialize()

func can_trigger(game_state) -> bool:
	if not .can_trigger(game_state):
		return false
	
	# Only trigger during awards season (January-March)
	var month = game_state.world_state.current_date.month
	return month >= 1 and month <= 3

func initialize():
	# Choice A: Console losers
	var choice_a = EventChoice.new()
	choice_a.choice_id = "console_losers"
	choice_a.label = "Console the Losers"
	choice_a.description = "Your client didn't win. Focus on damage control and building relationships with other losers."
	
	var outcome_a = EventOutcome.new()
	outcome_a.outcome_description = "You build solidarity with other disappointed nominees. These connections pay off later."
	outcome_a.base_probability = 1.0
	outcome_a.client_satisfaction_change = 15
	outcome_a.add_flags = ["loser_solidarity", "networking_bonus"]
	
	choice_a.outcomes = [outcome_a]
	
	# Choice B: Court winners
	var choice_b = EventChoice.new()
	choice_b.choice_id = "court_winners"
	choice_b.label = "Schmooze the Winners"
	choice_b.description = "Winners have power. Spend the night networking with people at the top of their game."
	
	var outcome_b_success = EventOutcome.new()
	outcome_b_success.outcome_description = "You make valuable connections with A-listers. Doors open for future collaborations."
	outcome_b_success.base_probability = 0.6
	outcome_b_success.reputation_change = 15
	outcome_b_success.add_flags = ["a_list_connections"]
	
	var outcome_b_fail = EventOutcome.new()
	outcome_b_fail.outcome_description = "You come across as a shameless social climber. Your client notices your priorities."
	outcome_b_fail.base_probability = 0.4
	outcome_b_fail.client_satisfaction_change = -20
	
	choice_b.outcomes = [outcome_b_success, outcome_b_fail]
	
	# Choice C: Paparazzi moment
	var choice_c = EventChoice.new()
	choice_c.choice_id = "paparazzi_moment"
	choice_c.label = "Stage a Paparazzi Moment"
	choice_c.description = "Win or lose, create a memorable photo opportunity that will dominate tomorrow's headlines."
	
	var outcome_c_success = EventOutcome.new()
	outcome_c_success.outcome_description = "Perfect execution! The photo goes viral and your client trends worldwide."
	outcome_c_success.base_probability = 0.5
	outcome_c_success.reputation_change = 25
	outcome_c_success.add_flags = ["viral_moment", "publicity_master"]
	
	var outcome_c_fail = EventOutcome.new()
	outcome_c_fail.outcome_description = "It looks forced and desperate. Critics mock the obvious publicity grab."
	outcome_c_fail.base_probability = 0.5
	outcome_c_fail.reputation_change = -10
	
	choice_c.outcomes = [outcome_c_success, outcome_c_fail]
	
	# Choice D: Pitch drunk studio exec
	var choice_d = EventChoice.new()
	choice_d.choice_id = "drunk_pitch"
	choice_d.label = "Pitch to Drunk Studio Chief"
	choice_d.description = "The head of a major studio is three sheets to the wind. Perfect time to pitch that passion project."
	choice_d.required_skills = {"negotiation": 6}
	
	var outcome_d_success = EventOutcome.new()
	outcome_d_success.outcome_description = "They love it! A million-dollar handshake deal is struck. Details tomorrow."
	outcome_d_success.base_probability = 0.4
	outcome_d_success.skill_check = "negotiation"
	outcome_d_success.skill_check_bonus = 0.3
	outcome_d_success.money_change = 1000000
	outcome_d_success.add_flags = ["handshake_deal"]
	
	var outcome_d_fail = EventOutcome.new()
	outcome_d_fail.outcome_description = "They wake up tomorrow with no memory of the conversation and deny everything."
	outcome_d_fail.base_probability = 0.6
	
	choice_d.outcomes = [outcome_d_success, outcome_d_fail]
	
	choices = [choice_a, choice_b, choice_c, choice_d]
