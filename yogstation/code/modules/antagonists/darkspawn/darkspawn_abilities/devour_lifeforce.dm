//Instantly kills people who have had their will devoured, and heals you slightly
/datum/action/innate/darkspawn/devour_lifeforce
	name = "Devour Lifeforce"
	id = "devour_lifeforce"
	desc = "Kills nearby eligible targets, and heals you. To be eligible, they must be alive and recently drained by Devour Will, and not have a mindshield implant."
	button_icon_state = "devour_lifeforce"
	check_flags = AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	psi_cost = 60
	lucidity_price = 2

/datum/action/innate/darkspawn/devour_lifeforce/Activate()
	var/mob/living/carbon/human/H = owner
	if(!do_after(owner, 1 SECONDS, owner))
		return
	owner.visible_message(span_boldwarning("[owner] lets out a chilling cry!"), "<span class='velvet bold'>...wjz oanra</span><br>\
	[span_notice("You devour the life force from everyone nearby.")]")
	playsound(owner, 'yogstation/sound/ambience/antag/veil_mind_scream.ogg', 70)
	for(var/mob/living/L in view(7, owner))
		if(L == owner)
			continue
		if(issilicon(L))
			to_chat(L, span_ownerdanger("$@!) ERR: SYNAPTIC OVERLOAD ^!</"))
			SEND_SOUND(L, sound('sound/misc/interference.ogg', volume = 50))
			L.emote("alarm")
			L.Stun(20)
			L.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/static)
			L.clear_fullscreen("flash", 10)
			continue
		if(L.has_status_effect(STATUS_EFFECT_BROKEN_WILL) && !HAS_TRAIT(L,TRAIT_MINDSHIELD))
			L.adjustCloneLoss(40,0)
			L.death(FALSE)

			H.adjustToxLoss(-50)
			H.adjustOxyLoss(-50)
			H.adjustBruteLoss(-50)
			H.adjustFireLoss(-50)
		else
			L.adjustCloneLoss(20)
			L.confused += 5

			H.adjustToxLoss(-20)
			H.adjustOxyLoss(-20)
			H.adjustBruteLoss(-20)
			H.adjustFireLoss(-20)
			to_chat(L,span_boldwarning("You feel strange sucking sensation..., and also very dizzy"))
	return TRUE
