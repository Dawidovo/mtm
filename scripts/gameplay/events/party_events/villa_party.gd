extends BaseEvent
class_name VillaPartyEvent

func _init():
	event_id = "villa_party"
	event_type = "party"
	title = "The Producer's Villa Party"
	description = "You've been invited to an exclusive party at {PRODUCER_NAME}'s mansion in the Hills. These events can make or break careers."
	
	min_clients = 1
	min_reputation = 40.0
	probability_weight = 4.0
	can_repeat = true
	cooldown_months = 6
	
	initialize()

func initialize():
	# Choice A: Poker table
	var choice_a = EventChoice.new()
	choice_a.choice_id = "poker_game"
	choice_a.label = "Join the Poker Game"
	choice_a.description = "High stakes poker in the back room. Risk $50K for potential big wins and connections."
	choice_a.required_money = 50000
	
	var outcome_a_big_win = EventOutcome.new()
	outcome_a_big_win.outcome_description = "You crush it! Win $200K and the respect of powerful players at the table."
	outcome_a_big_win.base_probability = 0.3
	outcome_a_big_win.money_change = 150000  # Net +150K (won 200K, paid 50K buy-in)
	outcome_a_big_win.reputation_change = 20
	outcome_a_big_win.add_flags = ["poker_legend"]
	
	var outcome_a_small_win = EventOutcome.new()
	outcome_a_small_win.outcome_description = "You break even but make good conversation. Valuable connections established."
	outcome_a_small_win.base_probability = 0.4
	outcome_a_small_win.money_change = 0
	outcome_a_small_win.reputation_change = 5
	
	var outcome_a_loss = EventOutcome.new()
	outcome_a_loss.outcome_description = "You lose it all. The other players smell blood in the water."
	outcome_a_loss.base_probability = 0.3
	outcome_a_loss.money_change = -50000
	outcome_a_loss.reputation_change = -10
	
	choice_a.outcomes = [outcome_a_big_win, outcome_a_small_win, outcome_a_loss]
	
	# Choice B: Pool party shenanigans
	var choice_b = EventChoice.new()
	choice_b.choice_id = "pool_party"
	choice_b.label = "Join the Pool Scene"
	choice_b.description = "Stay with the fun crowd by the pool. Less business, more social connections."
	
	var outcome_b_success = EventOutcome.new()
	outcome_b_success.outcome_description = "You're the life of the party! Younger actors and directors want to work with you."
	outcome_b_success.base_probability = 0.6
	outcome_b_success.reputation_change = 10
	outcome_b_success.add_flags = ["cool_agent_reputation"]
	
	var outcome_b_fail = EventOutcome.new()
	outcome_b_fail.outcome_description = "You come across as unprofessional. Senior executives take note."
	outcome_b_fail.base_probability = 0.4
	outcome_b_fail.reputation_change = -5
	
	choice_b.outcomes = [outcome_b_success, outcome_b_fail]
	
	# Choice C: Eavesdrop on office conversation
	var choice_c = EventChoice.new()
	choice_c.choice_id = "eavesdrop"
	choice_c.label = "Sneak Into the Office"
	choice_c.description = "You notice studio execs having a private conversation in the home office. Risky intel gathering."
	
	var outcome_c_jackpot = EventOutcome.new()
	outcome_c_jackpot.outcome_description = "You overhear details about an upcoming blockbuster casting. This information is gold!"
	outcome_c_jackpot.base_probability = 0.4
	outcome_c_jackpot.add_flags = ["insider_information", "casting_intel"]
	
	var outcome_c_nothing = EventOutcome.new()
	outcome_c_nothing.outcome_description = "They're just talking about golf. Waste of time."
	outcome_c_nothing.base_probability = 0.4
	
	var outcome_c_caught = EventOutcome.new()
	outcome_c_caught.outcome_description = "You're caught snooping! The host is furious and your reputation takes a hit."
	outcome_c_caught.base_probability = 0.2
	outcome_c_caught.reputation_change = -25
	outcome_c_caught.add_flags = ["untrustworthy_agent"]
	
	choice_c.outcomes = [outcome_c_jackpot, outcome_c_nothing, outcome_c_caught]
	
	# Choice D: Manage client drama
	var choice_d = EventChoice.new()
	choice_d.choice_id = "client_drama"
	choice_d.label = "Handle Your Client's Flirting"
	choice_d.description = "Your client is flirting dangerously with a married A-list star. Intervene or let it play out?"
	
	var outcome_d_intervene = EventOutcome.new()
	outcome_d_intervene.outcome_description = "You pull your client aside before things go too far. They're annoyed but grateful later."
	outcome_d_intervene.base_probability = 0.6
	outcome_d_intervene.client_satisfaction_change = 10
	outcome_d_intervene.add_flags = ["protective_moment"]
	
	var outcome_d_scandal = EventOutcome.new()
	outcome_d_scandal.outcome_description = "You intervene too late. Paparazzi photos leak and a scandal erupts."
	outcome_d_scandal.base_probability = 0.3
	outcome_d_scandal.client_satisfaction_change = -30
	outcome_d_scandal.reputation_change = -15
	outcome_d_scandal.add_flags = ["affair_scandal"]
	
	var outcome_d_connection = EventOutcome.new()
	outcome_d_connection.outcome_description = "You let it play out. Your client makes a powerful romantic connection that boosts their career."
	outcome_d_connection.base_probability = 0.1
	outcome_d_connection.client_satisfaction_change = 40
	outcome_d_connection.reputation_change = 20
	outcome_d_connection.add_flags = ["power_couple"]
	
	choice_d.outcomes = [outcome_d_intervene, outcome_d_scandal, outcome_d_connection]
	
	choices = [choice_a, choice_b, choice_c, choice_d]
