/datum/antagonist/hunter
	name = "Hunter demon"
	show_name_in_check_antagonists = TRUE
	job_rank = ROLE_ALIEN
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE


/datum/antagonist/hunter/on_gain()
	forge_objectives()
	. = ..()
/datum/antagonist/hunter/greet()
	. = ..()
	owner.announce_objectives()
	SEND_SOUND(owner.current, sound('sound/magic/ethereal_exit.ogg'))
	to_chat(owner.current, span_notice("<font color=\"#EE4000\">You are the Hunter Demon!</font>"))
	if(prob(10))
		to_chat(owner, span_warning("It's morbin' time!"))
		if(prob(10))
			name = "Morbius"

/datum/antagonist/hunter/proc/forge_objectives()
	var/datum/objective/new_objective = new
	new_objective.owner = owner
	new_objective.completed = TRUE
	objectives += new_objective
	new_objective.explanation_text = "Kill as many people as you can"
	var/datum/objective/survive/survival = new
	survival.owner = owner
	objectives += survival 

/mob/living/proc/what_am_i()
	set name = "Hunter Demon Help"
	set category = "Mentor"
	var/datum/antagonist/hunter/hunterdatum = mind.has_antag_datum(/datum/antagonist/hunter)
	if(!hunterdatum)
		return
	to_chat(usr, span_warning("As a hunter demon, you:\
	1. Need to hunt and kill targets. These are chosen through your blood orb by your master, or by you if you are unbound.\
	2. Can warp out of reality to move faster and through walls, but you can only warp back into reality near your target or blood orb!\
	3. Are most likely bound by a binding rite. While your orb is filled with blood from your master, you cannot attack them.\
	4. Can choose targets for yourself only if you do not have an active master or binding rite, or there is no blood currently sacrificed by them.\
	5. Passivly regenerate health while not in the mortal reality at the cost of sacrificed blood, and blood gained from attacking people\
	6. Attacking people gives you some blood, and regenerates you some health. Attacking the same person multiple times increases the chance of a special attack.\
	7. Loose health while not near your orb or your target, and move slower.\
	8. Die, if your orb is destroyed."))


