/datum/action/changeling/fake
	name = "Reviving Stasis"
	desc = "We fall into a stasis, allowing us to regenerate and trick our enemies. Costs 15 chemicals."
	button_icon_state = "fake_"
	chemical_cost = 1 // fucking jelly was right, I blame ling for merging it >:(
	dna_cost = 0
	req_dna = 1
	req_stat = DEAD
	ignores_fake = TRUE
	var/revive_ready = FALSE
	var/regain_respec = TRUE //variable to figure out if we give them the ability to respec again after they revive
	

//Fake our own  and fully heal. You will appear to be dead but regenerate fully after a short delay.
/datum/action/changeling/fake/sting_action(mob/living/user)
	..()
	if(revive_ready)
		INVOKE_ASYNC(src, .proc/revive, user)
		revive_ready = FALSE
		name = "Reviving Stasis"
		desc = "We fall into a stasis, allowing us to regenerate and trick our enemies."
		button_icon_state = "fake_"
		UpdateButtonIcon()
		chemical_cost = 15
		to_chat(user, span_notice("We have revived ourselves."))
		var/datum/antagonist/changeling/C = user.mind.has_antag_datum(/datum/antagonist/changeling)
		if(C)
			C.canrespec = regain_respec
	else
		to_chat(user, span_notice("We begin our stasis, preparing energy to arise once more."))
		if(user.stat != DEAD)
			user.tod = station_time_timestamp()
		user.fake("changeling") //play dead
		user.update_stat()
		user.update_mobility()
		var/datum/antagonist/changeling/C = user.mind.has_antag_datum(/datum/antagonist/changeling)
		if(C)
			regain_respec = C.canrespec
			C.canrespec = FALSE
		addtimer(CALLBACK(src, .proc/ready_to_regenerate, user), LING_FAKE_TIME, TIMER_UNIQUE)
	return TRUE

/datum/action/changeling/fake/proc/revive(mob/living/user)
	if(!user || !istype(user))
		return
	user.cure_fake("changeling")
	user.revive(full_heal = TRUE)
	var/list/missing = user.get_missing_limbs()
	missing -= BODY_ZONE_HEAD // headless changelings are funny
	if(missing.len)
		playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user]'s missing limbs \
			reform, making a loud, grotesque sound!</span>",
			"<span class='userdanger'>Your limbs regrow, making a \
			loud, crunchy sound and giving you great pain!</span>",
			"<span class='italics'>You hear organic matter ripping \
			and tearing!</span>")
		user.emote("scream")
		user.regenerate_limbs(0, list(BODY_ZONE_HEAD))
	user.regenerate_organs()

/datum/action/changeling/fake/proc/ready_to_regenerate(mob/user)
	if(user && user.mind)
		var/datum/antagonist/changeling/C = user.mind.has_antag_datum(/datum/antagonist/changeling)
		if(C && C.purchasedpowers)
			to_chat(user, span_notice("We are ready to revive."))
			name = "Revive"
			desc = "We arise once more."
			button_icon_state = "revive"
			UpdateButtonIcon()
			chemical_cost = 0
			revive_ready = TRUE

/datum/action/changeling/fake/can_sting(mob/living/user)
	if(HAS_TRAIT_FROM(user, TRAIT_COMA, "changeling") && !revive_ready)
		to_chat(user, span_warning("We are already reviving."))
		return
	if(!user.stat && !revive_ready) //Confirmation for living changelings if they want to fake their 
		switch(alert("Are we sure we wish to fake our own ?",,"Yes", "No"))
			if("No")
				return
	return ..()
