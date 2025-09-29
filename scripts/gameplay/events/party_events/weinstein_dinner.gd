extends BaseEvent
class_name WeinsteinDinnerEvent

func _init():
	event_id = "weinstein_dinner"
	event_type = "business"
	title = "The Producer's Dinner Invitation"
	description = "Powerful producer {PRODUCER_NAME} invites your client {CLIENT_NAME} to a 'business dinner' at their hotel suite. The role being discussed could make their career."
	
	min_clients = 1
	max_year = 2017  # Pre-MeToo
	probability_weight = 3.0
	can_repeat = false
	
	initialize()

func initialize():
	# Choice A: Decline with excuse
	var choice_a = EventChoice.new()
	choice_a.choice_id = "decline_meeting"
	choice_a.label = "Decline the Meeting"
	choice_a.description = "Make up an excuse and politely decline. The role is lost, but your client stays safe."
	
	var outcome_a = EventOutcome.new()
	outcome_a.outcome_description = "The role goes to someone else. Your client is disappointed but respects your protective instinct."
	outcome_a.base_probability = 1.0
	outcome_a.client_satisfaction_change = -10
	outcome_a.relationship_changes = {producer_name: -20}
	outcome_a.add_flags = ["integrity_score_+1"]
	
	choice_a.outcomes = [outcome_a]
	
	# Choice B: Insist on attending
	var choice_b = EventChoice.new()
	choice_b.choice_id = "attend_together"
	choice_b.label = "Insist You Attend Too"
	choice_b.description = "Make it clear that you'll be joining the meeting. This is business, after all."
	
	var outcome_b_success = EventOutcome.new()
	outcome_b_success.outcome_description = "The producer reluctantly agrees. The meeting stays professional and the deal has a 50/50 chance."
	outcome_b_success.base_probability = 0.6
	outcome_b_success.reputation_change = 5
	outcome_b_success.add_flags = ["protective_agent_reputation"]
	
	var outcome_b_fail = EventOutcome.new()
	outcome_b_fail.outcome_description = "The producer cancels the meeting entirely. Word spreads that you're 'difficult to work with.'"
	outcome_b_fail.base_probability = 0.4
	outcome_b_fail.reputation_change = -15
	outcome_b_fail.add_flags = ["difficult_agent_label"]
	
	choice_b.outcomes = [outcome_b_success, outcome_b_fail]
	
	# Choice C: Hidden recording device
	var choice_c = EventChoice.new()
	choice_c.choice_id = "recording_device"
	choice_c.label = "Provide Hidden Recording"
	choice_c.description = "Give your client a hidden recording device. Risky, but could provide insurance."
	choice_c.required_money = 5000
	
	var outcome_c_evidence = EventOutcome.new()
	outcome_c_evidence.outcome_description = "Damning evidence is recorded. You now have blackmail material for future leverage."
	outcome_c_evidence.base_probability = 0.3
	outcome_c_evidence.add_flags = ["blackmail_material_" + producer_name]
	outcome_c_evidence.money_change = -5000
	
	var outcome_c_nothing = EventOutcome.new()
	outcome_c_nothing.outcome_description = "Nothing incriminating happens, or the recording quality is too poor. You wasted $5000."
	outcome_c_nothing.base_probability = 0.5
	outcome_c_nothing.money_change = -5000
	
	var outcome_c_discovered = EventOutcome.new()
	outcome_c_discovered.outcome_description = "The device is discovered! You're now blacklisted by a major studio."
	outcome_c_discovered.base_probability = 0.2
	outcome_c_discovered.money_change = -5000
	outcome_c_discovered.reputation_change = -30
	outcome_c_discovered.add_flags = ["blacklisted_major_studio"]
	
	choice_c.outcomes = [outcome_c_evidence, outcome_c_nothing, outcome_c_discovered]
	
	# Choice D: Warn but let client decide
	var choice_d = EventChoice.new()
	choice_d.choice_id = "client_choice"
	choice_d.label = "Warn Client, Let Them Decide"
	choice_d.description = "Explain the risks clearly and let your client make their own choice."
	
	var outcome_d_ambitious = EventOutcome.new()
	outcome_d_ambitious.outcome_description = "Your ambitious client goes anyway. They have a bad experience that damages their mental health."
	outcome_d_ambitious.base_probability = 0.7
	outcome_d_ambitious.client_satisfaction_change = -50
	outcome_d_ambitious.add_flags = ["client_trauma", "producer_harassment"]
	
	var outcome_d_cautious = EventOutcome.new()
	outcome_d_cautious.outcome_description = "Your client declines after your warning. They thank you for your honesty and trust deepens."
	outcome_d_cautious.base_probability = 0.3
	outcome_d_cautious.client_satisfaction_change = 20
	outcome_d_cautious.add_flags = ["trust_bonus"]
	
	choice_d.outcomes = [outcome_d_ambitious, outcome_d_cautious]
	
	choices = [choice_a, choice_b, choice_c, choice_d]
