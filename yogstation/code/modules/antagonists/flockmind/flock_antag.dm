/datum/antagonist/flocktrace
	name = "Flocktrace"
	roundend_category = "flock"
	antagpanel_category = "Flock"
	show_to_ghosts = TRUE
	job_rank = ROLE_FLOCKTRACE	

/datum/antagonist/flocktrace/on_gain()
	var/datum/objective/flock_objective/FO = new
	FO.owner = owner
	objectives += FO
	. = ..()

/datum/antagonist/flocktrace/greet()
	to_chat(owner.current, span_userdanger("You are a Flocktrace"))
	to_chat(owner.current, span_warning("You are able to posses flockdrones by clicking on them. Piloting flockdrones is your primary purpose."))
	owner.announce_objectives()

/datum/objective/flock_objective
	name = "Flock Objective"
	explanation_text = "Unleash The Signal"

/datum/objective/flock_objective/check_completion()
	var/datum/team/flock/flock = GLOB.flock
	return flock.winner

/datum/antagonist/flocktrace/flockmind
	name = "Flockmind"
	job_rank = ROLE_FLOCKMIND

/datum/antagonist/flocktrace/flockmind/greet()
	to_chat(owner.current, span_userdanger("You are the Flockmind!"))
	to_chat(owner.current, span_warning("Firstly, you need to bring your Flock to this world, by creating a rift. After that, you will get all of your abilities."))
	to_chat(owner.current, span_warning("You can posses flockdrones by clicking them, and order them to do something by middle-clicking them."))
	to_chat(owner.current, span_warning("Your main goal is to build and protect The Relay for 6 minutes. Building it will require 1000 total compute and resources."))
	to_chat(owner.current, span_warning("If you will run out of drones AND compute, you will die. This can happend only after placing the rift."))
	owner.announce_objectives()
