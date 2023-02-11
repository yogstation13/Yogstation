//Instantly kills people who have had their will devoured, and heals you slightly
/datum/action/innate/darkspawn/devour_lifeforce
	name = "Devour Lifeforce"
	id = "devour_lifeforce"
	desc = "Kills nearby eligible targets, and heals you. To be eligible, they must be alive and recently drained by Devour Will, and not have a mindshield implant."
	button_icon_state = "devour_lifeforce"
	check_flags = AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	psi_cost = 60 //since this is only useful when cast directly after a succ it should be pretty expensive
	lucidity_price = 2

/datum/action/innate/darkspawn/devour_lifeforce/Activate()
	var/mob/living/carbon/human/H = owner
	if(!do_after(owner, 1 SECONDS, owner))
		return
	owner.visible_message(span_boldwarning("[owner] lets out a chilling cry!"), "<span class='velvet bold'>...wjz oanra</span><br>\
	[span_notice("You devour the life force from everyone nearby.")]")
	playsound(owner, 'yogstation/sound/ambience/antag/veil_mind_scream.ogg', 100)
	for(var/mob/living/L in view(3, owner))
		if(L == owner)
			continue
		if(L.has_status_effect(STATUS_EFFECT_BROKEN_WILL) && !HAS_TRAIT(L,TRAIT_MINDSHIELD))
			L.death(FALSE)
			H.adjustToxLoss(-20, 0)
			H.adjustOxyLoss(-20, 0)
			H.adjustBruteLoss(-20, 0)
			H.adjustFireLoss(-20, 0)
		else
			to_chat(L,span_boldwarning("You feel a strange sucking sensation..."))
	return TRUE
