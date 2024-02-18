// This is to replace the previous datum/disease/alien_embryo for slightly improved handling and maintainability
// It functions almost identically (see code/datums/diseases/alien_embryo.dm)
/obj/item/organ/body_egg/alien_embryo
	name = "alien embryo"
	icon = 'icons/mob/alien.dmi'
	icon_state = "larva0_dead"
	/// How long it has been growing, increases by up to 3 every 2 seconds based on the state of the host
	var/growth_progress = 0
	/// At what point can it burst
	var/burst_threshold = 270
	/// what "stage" we are at (used for image handling)
	var/current_stage = 0
	/// Are we in the process of bursting out of the poor sucker who's the xeno mom?
	var/bursting = FALSE

/obj/item/organ/body_egg/alien_embryo/Initialize(mapload)
	. = ..()
	RefreshInfectionImage()

/obj/item/organ/body_egg/alien_embryo/on_find(mob/living/finder)
	..()
	if(current_stage < 5)
		to_chat(finder, span_notice("It's small and weak, barely the size of a foetus."))
	else
		to_chat(finder, "It's grown quite large, and writhes slightly as you look at it.")
		if(prob(10))
			AttemptGrow(0)

/obj/item/organ/body_egg/alien_embryo/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent(/datum/reagent/toxin/acid, 10)
	return S

/obj/item/organ/body_egg/alien_embryo/on_life()
	if(owner.buckling && istype(owner.buckling, /obj/structure/bed/nest))
		growth_progress += 2 //doesn't get the extra progress if the host is either dead or not buckled to an alien bed
	switch(current_stage)
		if(3, 4)
			if(prob(2))
				owner.emote("sneeze")
			if(prob(2))
				owner.emote("cough")
			if(prob(2))
				to_chat(owner, span_danger("Your throat feels sore."))
			if(prob(2))
				to_chat(owner, span_danger("Mucous runs down the back of your throat."))
		if(5)
			if(prob(2))
				owner.emote("sneeze")
			if(prob(2))
				owner.emote("cough")
			if(prob(4))
				to_chat(owner, span_danger("Your muscles ache."))
				if(prob(20))
					owner.take_bodypart_damage(1)
			if(prob(4))
				to_chat(owner, span_danger("Your stomach hurts."))
				if(prob(20))
					owner.adjustToxLoss(1)
		if(5)
			to_chat(owner, span_danger("You feel something tearing its way out of your stomach..."))
			owner.adjustToxLoss(10)

/obj/item/organ/body_egg/alien_embryo/egg_process()
	growth_progress ++ //continues to progress even if the host is dead

	var/stage = clamp(round((growth_progress / burst_threshold) * 6), 0, 5)
	if(stage != current_stage) //if we've gone through a progress threshold, update the icon
		current_stage = stage
		RefreshInfectionImage()

	if(growth_progress >= burst_threshold && prob(50))
		for(var/datum/surgery/S in owner.surgeries)
			if(S.location == BODY_ZONE_CHEST && istype(S.get_surgery_step(), /datum/surgery_step/manipulate_organs))
				AttemptGrow(0)
				return
		AttemptGrow()


/obj/item/organ/body_egg/alien_embryo/proc/AttemptGrow(gib_on_success=TRUE)
	if(!owner || bursting)
		return

	bursting = TRUE

	var/list/candidates = pollGhostCandidates("Do you want to play as an alien larva that will burst out of [owner]?", ROLE_ALIEN, null, ROLE_ALIEN, 100, POLL_IGNORE_ALIEN_LARVA)

	if(QDELETED(src) || QDELETED(owner))
		return

	if(!candidates.len || !owner)
		bursting = FALSE
		// If no ghosts sign up for the Larva, let's regress our growth by twenty percent, we will try again!
		growth_progress = max(growth_progress - (burst_threshold*0.2), 0)
		current_stage = clamp(round((growth_progress / burst_threshold) * 6), 0, 5)
		RefreshInfectionImage()
		return

	var/mob/dead/observer/ghost = pick(candidates)

	var/mutable_appearance/overlay = mutable_appearance('icons/mob/alien.dmi', "burst_lie")
	owner.add_overlay(overlay)

	var/atom/xeno_loc = get_turf(owner)
	var/mob/living/carbon/alien/larva/new_xeno = new(xeno_loc)
	new_xeno.key = ghost.key
	SEND_SOUND(new_xeno, sound('sound/voice/hiss5.ogg',0,0,0,100))	//To get the player's attention
	new_xeno.mobility_flags = NONE //so we don't move during the bursting animation
	new_xeno.notransform = 1
	new_xeno.invisibility = INVISIBILITY_MAXIMUM

	sleep(0.6 SECONDS)

	if(QDELETED(src) || QDELETED(owner))
		return

	if(new_xeno)
		new_xeno.mobility_flags = MOBILITY_FLAGS_DEFAULT
		new_xeno.notransform = 0
		new_xeno.invisibility = 0

	if(gib_on_success)
		new_xeno.visible_message(span_danger("[new_xeno] bursts out of [owner] in a shower of gore!"), span_userdanger("You exit [owner], your previous host."), span_italics("You hear organic matter ripping and tearing!"))
		var/obj/item/organ/brain/BR = owner.getorgan(/obj/item/organ/brain) //yogs start
		if(BR)
			BR.setOrganDamage(maxHealth) //trauma from having a FUCKING XENO COME OUT OF YOUR BODY
		owner.gib()             //yogs end
	else
		new_xeno.visible_message(span_danger("[new_xeno] wriggles out of [owner]!"), span_userdanger("You exit [owner], your previous host."))
		owner.adjustBruteLoss(40)
		owner.cut_overlay(overlay)
	qdel(src)


/*----------------------------------------
Proc: AddInfectionImages(C)
Des: Adds the infection image to all aliens for this embryo
----------------------------------------*/
/obj/item/organ/body_egg/alien_embryo/AddInfectionImages()
	for(var/mob/living/carbon/alien/alien in GLOB.player_list)
		if(alien.client)
			var/I = image('icons/mob/alien.dmi', loc = owner, icon_state = "infected[current_stage]")
			alien.client.images += I

/*----------------------------------------
Proc: RemoveInfectionImage(C)
Des: Removes all images from the mob infected by this embryo
----------------------------------------*/
/obj/item/organ/body_egg/alien_embryo/RemoveInfectionImages()
	for(var/mob/living/carbon/alien/alien in GLOB.player_list)
		if(alien.client)
			for(var/image/I in alien.client.images)
				var/searchfor = "infected"
				if(I.loc == owner && findtext(I.icon_state, searchfor, 1, length(searchfor) + 1))
					qdel(I)
