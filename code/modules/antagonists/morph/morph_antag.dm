/datum/antagonist/morph
	name = "Morph"
	show_name_in_check_antagonists = TRUE
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE

/datum/antagonist/morph/roundend_report()
	var/list/parts = list()
	parts += printplayer(owner)
	if(istype(owner.current, /mob/living/simple_animal/hostile/morph))
		var/mob/living/simple_animal/hostile/morph/M = owner.current
		parts += "Things eaten: [M.eat_count]"
		parts += "Corpses eaten: [M.corpse_eat_count]"
	parts += printobjectives(objectives)
	return parts.Join("<br>")

/datum/antagonist/morph/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/morph/proc/forge_objectives()
	if(prob(33)) // Get both objectives
		var/datum/objective/morph_eat_things/eat = new
		eat.owner = owner
		eat.update_explanation_text()
		objectives += eat // Consume x objects
		var/datum/objective/morph_eat_corpses/eatcorpses = new
		eatcorpses.owner = owner
		eatcorpses.update_explanation_text()
		objectives += eatcorpses // Consume x corpses
	else
		if(prob(50))
			var/datum/objective/morph_eat_things/eat = new
			eat.owner = owner
			eat.update_explanation_text()
			objectives += eat // Consume x objects
		else
			var/datum/objective/morph_eat_corpses/eatcorpses = new
			eatcorpses.owner = owner
			eatcorpses.update_explanation_text()
			objectives += eatcorpses // Consume x corpses

	var/datum/objective/survive/survival = new
	survival.owner = owner
	objectives += survival // Don't die, idiot



/datum/antagonist/morph/greet()
	owner.announce_objectives()


// Consume x objects
/datum/objective/morph_eat_things
	name = "morph eat objective"
	explanation_text = "Eat things."
	var/target_things

/datum/objective/morph_eat_things/update_explanation_text()
	..()
	if(!target_things)
		target_things = rand(20,60)
	explanation_text = "Eat at least [target_things] things."

/datum/objective/morph_eat_things/check_completion()
	if(..())
		return TRUE
	if(istype(owner.current, /mob/living/simple_animal/hostile/morph))
		var/mob/living/simple_animal/hostile/morph/M = owner.current
		return M.eat_count >= target_things


// Consume x corpses
/datum/objective/morph_eat_corpses
	name = "morph eat corpses objective"
	explanation_text = "Eat corpses."
	var/target_corpses

/datum/objective/morph_eat_corpses/update_explanation_text()
	..()
	if(!target_corpses)
		target_corpses = rand(2,6)
	explanation_text = "Eat at least [target_corpses] corpses."

/datum/objective/morph_eat_corpses/check_completion()
	if(..())
		return TRUE
	if(istype(owner.current, /mob/living/simple_animal/hostile/morph))
		var/mob/living/simple_animal/hostile/morph/M = owner.current
		return M.corpse_eat_count >= target_corpses

