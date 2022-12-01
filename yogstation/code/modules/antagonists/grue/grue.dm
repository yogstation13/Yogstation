/datum/antagonist/grue
	name = "Grue"
	job_rank = ROLE_GRUE
	roundend_category = "grues"
	antagpanel_category = "Grues"
	var/eaten_count = 0
	var/spawn_count = 0

	var/is_hatched = FALSE

/datum/antagonist/grue/greet()
	to_chat(owner?.current?.client, span_alertsyndie("You are a grue."))
	to_chat(owner?.current?.client, span_warning("Darkness is your ally; bright light is harmful to your kind. You hunger... specifically for sentient beings, but you are still young and cannot eat until you are fully mature."))
	to_chat(owner?.current?.client, span_warning("Bask in shadows to prepare to moult. The more sentient beings you eat, the more powerful you will become."))

/datum/antagonist/grue/on_gain()
	. = ..()
	if (!is_hatched)
		objectives += new /datum/objective/grue/eat_sentients
		objectives += new /datum/objective/grue/spawn_offspring

/datum/antagonist/grue/hatched
	name = "Fresh Grue"
	is_hatched = TRUE

/datum/antagonist/grue/hatched/on_gain()
	. = ..()
	objectives += new /datum/objective/grue/grue_basic
	
/datum/objective/grue/grue_basic
	explanation_text = "Lurk in the darkness and eat as many sentient beings as you can."
	name = "Lurk and Eat"
	completed = TRUE

/datum/objective/grue/grue_basic/check_completion()
	. = ..()

/datum/objective/grue/eat_sentients
	explanation_text = "Eat sentient beings."
	name = "Eat Sentients"
	var/eat_objective = 2

/datum/objective/grue/eat_sentients/New(text)
	. = ..()
	eat_objective = rand(2,3)
	explanation_text = "Eat [eat_objective] sentient being[(eat_objective>1) ? "" : "s"]."

/datum/objective/grue/eat_sentients/update_explanation_text()
	. = ..()
	explanation_text = "Eat [eat_objective] sentient being[(eat_objective>1) ? "" : "s"]."

/datum/objective/grue/eat_sentients/check_completion()
	if (..())
		return TRUE
	var/datum/antagonist/grue/G = owner.has_antag_datum(/datum/antagonist/grue)
	return (G.eaten_count >= eat_objective)

/datum/objective/grue/spawn_offspring
	explanation_text = "Lay eggs and spawn offspring."
	name = "Spawn Offspring"
	var/spawn_objective = 2

/datum/objective/grue/spawn_offspring/New(text)
	. = ..()
	spawn_objective = rand(1,2)
	explanation_text = "Lay [(spawn_objective>1) ? "an egg" : "eggs"] and spawn [spawn_objective] offspring."

/datum/objective/grue/spawn_offspring/update_explanation_text()
	. = ..()
	explanation_text = "Lay [(spawn_objective>1) ? "an egg" : "eggs"] and spawn [spawn_objective] offspring."

/datum/objective/grue/spawn_offspring/check_completion()
	if (..())
		return TRUE
	var/datum/antagonist/grue/G = owner.has_antag_datum(/datum/antagonist/grue)
	return (G.spawn_count >= spawn_objective)

