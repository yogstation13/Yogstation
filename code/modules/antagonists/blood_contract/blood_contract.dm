/datum/antagonist/blood_contract
	name = "Blood Contract Target"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	var/duration = 2 MINUTES

/datum/antagonist/blood_contract/on_gain()
	. = ..()
	give_objective()
	start_the_hunt()

/datum/antagonist/blood_contract/proc/give_objective()
	var/datum/objective/survive/survive = new
	survive.owner = owner
	objectives += survive

/datum/antagonist/blood_contract/greet()
	. = ..()
	to_chat(owner, span_userdanger("You've been marked for ! Don't let the demons get you! KILL THEM ALL!"))

/datum/antagonist/blood_contract/proc/start_the_hunt()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return

	H.add_atom_colour("#FF0000", ADMIN_COLOUR_PRIORITY)

	var/obj/effect/mine/pickup/bloodbath/B = new(H)
	B.duration = duration

	INVOKE_ASYNC(B, /obj/effect/mine/pickup/bloodbath/.proc/mineEffect, H) //could use moving out from the mine

	for(var/mob/living/carbon/human/P in GLOB.player_list)
		if(P == H)
			continue
		to_chat(P, span_userdanger("You have an overwhelming desire to kill [H]. [H.p_theyve(TRUE)] been marked red! Whoever [H.p_they()] [H.p_were()], friend or foe, go kill [H.p_them()]!"))

		var/obj/item/I = new /obj/item/kitchen/knife/butcher(get_turf(P))
		P.put_in_hands(I, del_on_fail=TRUE)
		QDEL_IN(I, duration)
		INVOKE_ASYNC(src, .proc/end_the_hunt, duration, P)
	INVOKE_ASYNC(src, .proc/end_the_hunt, duration + (0.5 SECONDS), null)
		

/datum/antagonist/blood_contract/proc/end_the_hunt(delay, mob/living/carbon/human/P)
	if(delay > 0)
		sleep(delay)
	if(P) // Ending the hunt for a specific person
		to_chat(P, span_userdanger("You no longer have an overwhelming desire to kill [owner.current]."))
		return
	
	// Removing self from target
	owner.current.remove_atom_colour("#FF0000", ADMIN_COLOUR_PRIORITY)
	on_removal() // Remove this antag datum
	return

