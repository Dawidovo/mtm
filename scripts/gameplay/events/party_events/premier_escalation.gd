extends BaseEvent
class_name PremiereEscalationEvent

func _init():
	event_id = "premiere_escalation"
	event_type = "party"
	title = "Premiere Party Escalation"
	description = "The premiere of {CLIENT_NAME}'s new film '{MOVIE_TITLE}' is in full swing. Suddenly, their ex-partner {EX_NAME} shows up drunk and makes a scene."
	
	min_clients = 1
	probability_weight = 5.0
	can_repeat = true
	cooldown_months = 6
	
	initialize()

func initialize():
	# Choice A: Discreet security
	var choice_a = EventChoice.new()
	choice_a.choice_id = "security_discreet"
	choice_a.label = "Inform Security Discreetly"
	choice_a.description = "Have security quietly remove the ex-partner before things escalate."
	
	var outcome_a_success = EventOutcome.new()
	outcome_a_success.outcome_description = "Security handles it professionally. The ex is quietly escorted out and the press doesn't notice anything unusual."
	outcome_a_success.base_probability = 0.7
	outcome_a_success.reputation_change = 5
	outcome_a_success.client_satisfaction_change = 10
	
	var outcome_a_fail = EventOutcome.new()
	outcome_a_fail.outcome_description = "Security is too aggressive. The press notices and captures photos of the commotion."
	outcome_a_fail.base_probability = 0.3
	outcome_a_fail.reputation_change = -5
	outcome_a_fail.add_flags = ["premiere_scandal_" + event_id]
	
	choice_a.outcomes = [outcome_a_success, outcome_a_fail]
	
	# Choice B: Personal intervention
	var choice_b = EventChoice.new()
	choice_b.choice_id = "intervene_personal"
	choice_b.label = "Intervene Personally"
	choice_b.description = "Step in yourself and try to defuse the situation with your charm and diplomacy."
	
	var outcome_b_success = EventOutcome.new()
	outcome_b_success.outcome_description = "You successfully calm the situation. The ex-partner apologizes and leaves peacefully. Your client is impressed by your handling."
	outcome_b_success.base_probability = 0.5
	outcome_b_success.skill_check = "charm"
	outcome_b_success.skill_check_bonus = 0.3
	outcome_b_success.client_satisfaction_change = 15
	outcome_b_success.reputation_change = 10
	outcome_b_success.trigger_events = ["ex_as_new_client"]  # Unlock possibility to sign the ex
	
	var outcome_b_fail = EventOutcome.new()
	outcome_b_fail.outcome_description = "Things spiral out of control. A physical altercation breaks out and you're caught in the middle. Cameras catch everything."
	outcome_b_fail.base_probability = 0.5
	outcome_b_fail.client_satisfaction_change = -20
	outcome_b_fail.reputation_change = -10
	outcome_b_fail.money_change = -5000  # Medical bills
	
	choice_b.outcomes = [outcome_b_success, outcome_b_fail]
	
	# Choice C: Orchestrate press spectacle
	var choice_c = EventChoice.new()
	choice_c.choice_id = "press_spectacle"
	choice_c.label = "Turn It Into a Press Moment"
	choice_c.description = "Spin this as a 'passionate romance' story for maximum publicity."
	
	var outcome_c_success = EventOutcome.new()
	outcome_c_success.outcome_description = "The tabloids eat it up! 'Passionate Love Triangle' headlines boost the film's visibility significantly."
	outcome_c_success.base_probability = 0.4
	outcome_c_success.client_satisfaction_change = 20
	outcome_c_success.add_flags = ["publicity_boost_" + event_id]
	
	var outcome_c_fail = EventOutcome.new()
	outcome_c_fail.outcome_description = "The scandal becomes uncontrollable. Sponsors pull out and your client's reputation takes a hit."
	outcome_c_fail.base_probability = 0.6
	outcome_c_fail.client_satisfaction_change = -30
	outcome_c_fail.reputation_change = -15
	outcome_c_fail.add_flags = ["career_crisis"]
	
	choice_c.outcomes = [outcome_c_success, outcome_c_fail]
	
	# Choice D: Let client handle it
	var choice_d = EventChoice.new()
	choice_d.choice_id = "client_decides"
	choice_d.label = "Let Client Handle It"
	choice_d.description = "Step back and allow your client to handle their personal drama themselves."
	
	var outcome_d_dramatic = EventOutcome.new()
	outcome_d_dramatic.outcome_description = "Your client makes a dramatic scene. It's 50/50 whether this helps or hurts their image."
	outcome_d_dramatic.base_probability = 0.5
	outcome_d_dramatic.client_satisfaction_change = 10
	
	var outcome_d_professional = EventOutcome.new()
	outcome_d_professional.outcome_description = "Your client handles it professionally and with grace. The press respects their composure."
	outcome_d_professional.base_probability = 0.3
	outcome_d_professional.client_satisfaction_change = 10
	outcome_d_professional.reputation_change = 5
	
	var outcome_d_volatile = EventOutcome.new()
	outcome_d_volatile.outcome_description = "Your client completely loses it. The situation escalates into a full public meltdown."
	outcome_d_volatile.base_probability = 0.2
	outcome_d_volatile.client_satisfaction_change = -20
	outcome_d_volatile.reputation_change = -20
	outcome_d_volatile.add_flags = ["client_unstable"]
	
	choice_d.outcomes = [outcome_d_dramatic, outcome_d_professional, outcome_d_volatile]
	
	choices = [choice_a, choice_b, choice_c, choice_d]
