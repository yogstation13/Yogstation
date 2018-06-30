/obj/effect/proc_holder/spell/targeted/shadowconvert
	name = "Shadow Convert"
	desc = "Converts a dead body into a shadow-thrall."
	charge_max = 0
	clothes_req = 0
	phase_allowed = FALSE
	selection_type = "range"
	range = -1
	include_user = TRUE
	cooldown_min = 0
	overlay = null
	action_icon = 'icons/mob/actions/actions_xeno.dmi'
	action_icon_state = "alien_egg"
	action_background_icon_state = "bg_alien"
	var/isconverting

/obj/effect/proc_holder/spell/targeted/shadowconvert/cast(list/targets,mob/user = usr)
	if(isconverting)
		to_chat(user, "<span class='warning'>We are already converting!</span>")
		return

	if(!user.pulling || !iscarbon(user.pulling))
		to_chat(user, "<span class='warning'>We must be grabbing a creature to convert them!</span>")
		return

	if(user.grab_state <= GRAB_NECK)
		to_chat(user, "<span class='warning'>We must have a tighter grip to convert this creature!</span>")
		return

	var/mob/living/carbon/target = user.pulling
	if(!target.mind || (!target.ckey && !target.get_ghost().ckey) )
		to_chat(user, "<span class='warning'>Their mind is too empty!</span>")
		return

	if(target.isloyal())
		to_chat(user, "<span class='warning'>Their mind is protected!</span>")
		return

	if(istype(target.dna.species, /datum/species/shadow))
		to_chat(user, "<span class='warning'>Their mind is already full of darkness!</span>")
		return

	if(target.stat != DEAD)
		to_chat(user, "<span class='warning'>Their mind is still active!</span>")
		return

	isconverting = TRUE
	for(var/i in 1 to 3)
		switch(i)
			if(1)
				to_chat(user, "<span class='notice'>This person, their mind feels free...</span>")
			if(2)
				user.visible_message("<span class='warning'>[user] digs their Lighteater into [target]!</span>", "<span class='notice'>We begin digging into [target] </span>")
			if(3)
				user.visible_message("<span class='danger'>[target] seems to become darker!</span>", "<span class='notice'>We begin to corrupt [target].</span>")

		if(!do_mob(user, target, 150))
			to_chat(user, "<span class='warning'>Our conversion of [target] has been interrupted!</span>")
			isconverting = FALSE
			return

	user.visible_message("<span class='danger'>[user] corrupts [target]!</span>", "<span class='notice'>We have corrupted [target].</span>")
	target.set_species(/datum/species/shadow/nightmarethrall)
	if(!target.ckey)
		target.grab_ghost()

	target.revive()

	to_chat(target, "<span class='boldannounce'>You are now a servant of the nightmare, and must fullfill it's every bidding!</span>")
	if(target.mind && target.mind.special_role)
		to_chat(target, "<span class='notice'>This overrides any antagoniststatus you may have.</span>")
