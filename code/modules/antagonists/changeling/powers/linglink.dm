/datum/action/changeling/linglink
	name = "Hivemind Link"
	desc = "We link our victim's mind into the hivemind for personal interrogation."
	helptext = "If we find a human mad enough to support our cause, this can be a helpful tool to stay in touch."
	button_icon_state = "hivemind_link"
	chemical_cost = 0
	dna_cost = 0
	req_human = 1

/datum/action/changeling/linglink/can_sting(mob/living/carbon/user)
	if(!..())
		return
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(changeling.islinking)
		to_chat(user, span_warning("We have already formed a link with the victim!"))
		return
	if(!user.pulling)
		to_chat(user, span_warning("We must be tightly grabbing a creature to link with them!"))
		return
	if(!iscarbon(user.pulling))
		to_chat(user, span_warning("We cannot link with this creature!"))
		return
	var/mob/living/carbon/target = user.pulling

	if(!target.mind)
		to_chat(user, span_warning("The victim has no mind to link to!"))
		return
	if(target.stat == DEAD)
		to_chat(user, span_warning("The victim is dead, you cannot link to a dead mind!"))
		return
	if(target.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_warning("The victim is already a part of the hivemind!"))
		return
	if(user.grab_state <= GRAB_AGGRESSIVE)
		to_chat(user, span_warning("We must have a tighter grip to link with this creature!"))
		return
	return changeling.can_absorb_dna(target)

/datum/action/changeling/linglink/sting_action(mob/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	var/mob/living/carbon/human/target = user.pulling
	changeling.islinking = 1
	for(var/i in 1 to 3)
		switch(i)
			if(1)
				to_chat(user, span_notice("This creature is compatible. We must hold still..."))
			if(2)
				to_chat(user, span_notice("We stealthily stab [target] with a minor proboscis..."))
				to_chat(target, span_userdanger("You experience a stabbing sensation and your ears begin to ring..."))
			if(3)
				to_chat(user, span_notice("We mold the [target]'s mind like clay, granting [target.p_them()] the ability to speak in the hivemind!"))
				to_chat(target, span_userdanger("A migraine throbs behind your eyes, you hear yourself screaming - but your mouth has not opened!"))
				for(var/mi in GLOB.mob_list)
					var/mob/M = mi
					if(M.lingcheck() == LINGHIVE_LING)
						to_chat(M, span_changeling("We can sense a foreign presence in the hivemind..."))
				target.mind.linglink = 1
				target.say("[MODE_TOKEN_CHANGELING] AAAAARRRRGGGGGHHHHH!!")
				to_chat(target, "<span class='changeling bold'>You can now communicate in the changeling hivemind, say \"[MODE_TOKEN_CHANGELING] message\" to communicate!</span>")
				target.reagents.add_reagent(/datum/reagent/medicine/salbutamol, 40) // So they don't choke to  while you interrogate them
				sleep(3 MINUTES)
		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]", "[i]"))
		if(!do_mob(user, target, 20))
			to_chat(user, span_warning("Our link with [target] has ended!"))
			changeling.islinking = 0
			target.mind.linglink = 0
			return

	changeling.islinking = 0
	target.mind.linglink = 0
	to_chat(user, span_notice("You cannot sustain the connection any longer, your victim fades from the hivemind"))
	to_chat(target, span_userdanger("The link cannot be sustained any longer, your connection to the hivemind has faded!"))
