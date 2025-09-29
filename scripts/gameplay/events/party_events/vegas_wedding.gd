extends BaseEvent
class_name VegasWeddingEvent

func _init():
	event_id = "vegas_wedding"
	event_type = "scandal"
	title = "The Vegas Wedding"
	description = "{CLIENT_NAME} calls you drunk at 4 AM. They just married a {RANDOM_PERSON} in Vegas!"
	
	min_clients = 1
	probability_weight = 2.0
	can_repeat = true
	cooldown_months = 12
	
	initialize()

func initialize():
	# Generate random spouse type
	var spouse_types = ["stripper", "Elvis impersonator", "co-star", "random fan"]
	var random_person = spouse_types[randi() % spouse_types.size()]
	description = description.replace("{RANDOM_PERSON}", random_person)
	
	# Choice A: Immediate annulment
	var choice_a = EventChoice.new()
	choice_a.choice_id = "immediate_annulment"
	choice_a.label = "Get Annulment Immediately"
	choice_a.description = "Hire lawyers immediately to get this marriage annulled within 48 hours."
	choice_a.required_money = 30000
	
	var outcome_a_success = EventOutcome.new()
	outcome_a_success.outcome_description = "The annulment goes through smoothly. Crisis averted with minimal press coverage."
	outcome_a_success.base_probability = 0.8
	outcome_a_success.money_change = -30000
	outcome_a_success.reputation_change = -5
	outcome_a_success.client_satisfaction_change = 5
	
	var outcome_a_fail = EventOutcome.new()
	outcome_a_fail.outcome_description = "The spouse demands money. Public legal battle ensues."
	outcome_a_fail.base_probability = 0.2
	outcome_a_fail.money_change = -30000
	outcome_a_fail.reputation_change = -15
	outcome_a_fail.add_flags = ["divorce_drama"]
	
	choice_a.outcomes = [outcome_a_success, outcome_a_fail]
	
	# Choice B: Publicity stunt
	var choice_b = EventChoice.new()
	choice_b.choice_id = "publicity_stunt"
	choice_b.label = "Spin It as Romance"
	choice_b.description = "Sell this as a 'crazy love story' to the tabloids for maximum publicity."
	
	var outcome_b_success = EventOutcome.new()
	outcome_b_success.outcome_description = "It goes viral! Your client becomes a trending topic and their Q-score jumps."
	outcome_b_success.base_probability = 0.4
	outcome_b_success.reputation_change = 20
	outcome_b_success.client_satisfaction_change = 15
	outcome_b_success.add_flags = ["viral_moment"]
	
	var outcome_b_fail = EventOutcome.new()
	outcome_b_fail.outcome_description = "The public sees through it. Your client looks trashy and desperate."
	outcome_b_fail.base_probability = 0.6
	outcome_b_fail.reputation_change = -15
	outcome_b_fail.client_satisfaction_change = -10
	
	choice_b.outcomes = [outcome_b_success, outcome_b_fail]
	
	# Choice C: Make it real
	var choice_c = EventChoice.new()
	choice_c.choice_id = "make_it_real"
	choice_c.label = "Encourage the Relationship"
	choice_c.description = "Maybe it's actually true love? Support their impulsive decision."
	
	var outcome_c_success = EventOutcome.new()
	outcome_c_success.outcome_description = "Against all odds, it actually works out! A genuine love story unfolds."
	outcome_c_success.base_probability = 0.2
	outcome_c_success.client_satisfaction_change = 30
	outcome_c_success.reputation_change = 10
	outcome_c_success.add_flags = ["happy_marriage"]
	
	var outcome_c_fail = EventOutcome.new()
	outcome_c_fail.outcome_description = "Horrible divorce 6 months later. Messy public breakup damages your client's brand."
	outcome_c_fail.base_probability = 0.8
	outcome_c_fail.client_satisfaction_change = -40
	outcome_c_fail.reputation_change = -20
	outcome_c_fail.add_flags = ["divorce_scandal"]
	
	choice_c.outcomes = [outcome_c_success, outcome_c_fail]
	
	# Choice D: Pay off spouse
	var choice_d = EventChoice.new()
	choice_d.choice_id = "payoff_spouse"
	choice_d.label = "Pay Off the Spouse"
	choice_d.description = "Offer $100K for a quiet annulment. Clean and simple."
	choice_d.required_money = 100000
	
	var outcome_d = EventOutcome.new()
	outcome_d.outcome_description = "Deal done. The marriage disappears like it never happened. Your client learns a lesson."
	outcome_d.base_probability = 1.0
	outcome_d.money_change = -100000
	outcome_d.client_satisfaction_change = 10
	outcome_d.add_flags = ["professionalism_lesson"]
	
	choice_d.outcomes = [outcome_d]
	
	choices = [choice_a, choice_b, choice_c, choice_d]
