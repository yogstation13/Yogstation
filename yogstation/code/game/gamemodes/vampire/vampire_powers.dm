/datum/action/cooldown/spell
	var/gain_desc
	var/blood_used = 0
	var/vamp_req = FALSE

/datum/action/cooldown/spell/can_cast_spell(feedback = TRUE)
	if(vamp_req)
		if(!is_vampire(owner))
			return FALSE
		var/datum/antagonist/vampire/V = owner.mind.has_antag_datum(/datum/antagonist/vampire)
		if(!V)
			return FALSE
		if(V.usable_blood < blood_used)
			if(feedback)
				to_chat(owner, span_warning("You do not have enough blood to cast this!"))
			return FALSE
	return ..()

/datum/action/cooldown/spell/New()
	. = ..()
	if(vamp_req)
		spell_requirements = NONE

/datum/action/cooldown/spell/before_cast(atom/cast_on)
	if(vamp_req)
		// sanity check before we cast
		if(!is_vampire(owner))
			return

		if(!blood_used)
			return

		// enforce blood
		var/datum/antagonist/vampire/vampire = owner.mind.has_antag_datum(/datum/antagonist/vampire)

		if(blood_used <= vampire.usable_blood)
			vampire.usable_blood -= blood_used

		if(cast_on)
			to_chat(owner, span_notice("<b>You have [vampire.usable_blood] left to use.</b>"))

	return ..()

/datum/action/cooldown/spell/is_valid_target(mob/living/target)
	if(vamp_req && !is_vampire(target))
		return FALSE
	return ..()

/datum/vampire_passive
	var/gain_desc

/datum/vampire_passive/New()
	. = ..()
	if(!gain_desc)
		gain_desc = span_notice("You have gained \the [src] ability.")


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/vampire_passive/nostealth
	gain_desc = span_warning("You are no longer able to conceal yourself while sucking blood.") //gets a warning span because it's a downgrade

/datum/vampire_passive/regen
	gain_desc = span_notice("Your innate regenerative abilities have been improved, granting passive healing. Rejuvenate now also helps to reduce disabling effects.")

/datum/vampire_passive/vision
	gain_desc = span_notice("Your vampiric vision has improved.")

/datum/vampire_passive/full
	gain_desc = span_notice("You have reached your full potential and are no longer weak to the effects of anything holy and your vision has been improved greatly.")

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/rejuvenate
	name = "Rejuvenate (20)"
	desc= "Flush your system with some spare blood to restore stamina over time."
	button_icon_state = "rejuv"
	button_icon = 'yogstation/icons/mob/vampire.dmi'
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"

	school = SCHOOL_RESTORATION

	check_flags = NONE
	cooldown_time = 20 SECONDS
	blood_used = 20
	vamp_req = TRUE

/datum/action/cooldown/spell/rejuvenate/cast(mob/living/user)
	. = ..()
	if(!iscarbon(user))
		return FALSE
	var/mob/living/carbon/U = user
	heal(U)

/datum/action/cooldown/spell/rejuvenate/proc/heal(mob/living/carbon/user, iterations = 1)
	if(iterations > 5)//1 2 3 4 5 return, 5 total instances of stam heal each split by 1 second
		return
	user.remove_status_effect(/datum/status_effect/speech/stutter)

	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V) //sanity check
		return
	user.adjustStaminaLoss(-50)
	if(V.get_ability(/datum/vampire_passive/regen))
		user.AdjustAllImmobility(-1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(heal), user, iterations + 1), 1 SECONDS)

/datum/action/cooldown/spell/pointed/gaze
	name = "Vampiric Gaze"
	desc = "Paralyze your target with fear."
	ranged_mousepointer = 'icons/effects/mouse_pointers/gaze_target.dmi'
	button_icon = 'yogstation/icons/mob/vampire.dmi'
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"
	button_icon_state = "gaze"

	school = SCHOOL_SANGUINE

	cooldown_time = 30 SECONDS
	active_msg = "You prepare your vampiric gaze.</span>"
	deactive_msg = "You stop preparing your vampiric gaze.</span>"
	vamp_req = TRUE

/datum/action/cooldown/spell/pointed/gaze/is_valid_target(atom/target)
	. = ..()
	if(!.)
		return FALSE
	if(!target)
		return FALSE
	if(!ishuman(target))
		to_chat(owner, span_warning("Gaze will not work on this being."))
		return FALSE
	var/mob/living/carbon/human/T = target

	if(T.stat == DEAD)
		to_chat(owner,"<span class='warning'>You cannot gaze at corpses... \
			or maybe you could if you really wanted to.</span>")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/gaze/InterceptClickOn(mob/living/user, params, atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(target_atom))
		return FALSE

	var/mob/living/carbon/human/T = target_atom
	user.visible_message(span_warning("[user]'s eyes flash red."),\
					span_warning("your eyes flash red."))

	var/protection = T.get_eye_protection()
	switch(protection)
	
		if(0)
			to_chat(target, span_userdanger("You are paralyzed with fear!"))
			to_chat(user, span_notice("You paralyze [T]."))
			T.Stun(5 SECONDS)
		if(1 to INFINITY)
			T.adjust_confusion(5 SECONDS)
			return TRUE
		if(INFINITY)
			to_chat(user, span_vampirewarning("[T] is blind and is unaffected by your gaze!"))
			return FALSE
	return TRUE


/datum/action/cooldown/spell/pointed/hypno
	name = "Hypnotize (20)"
	desc = "Knock out your target."
	button_icon_state = "hypnotize"
	ranged_mousepointer = 'icons/effects/mouse_pointers/hypnotize_target.dmi'
	button_icon = 'yogstation/icons/mob/vampire.dmi'
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"

	school = SCHOOL_SANGUINE

	cooldown_time = 30 SECONDS
	blood_used = 20
	active_msg = span_warning("You prepare your hypnosis technique.")
	deactive_msg = span_warning("You stop preparing your hypnosis.")
	vamp_req = TRUE

/datum/action/cooldown/spell/pointed/hypno/is_valid_target(atom/target)
	if(!..())
		return FALSE
	if(!target)
		return FALSE
	if(!ishuman(target))
		to_chat(owner, span_warning("Hypnotize will not work on this being."))
		return FALSE

	var/mob/living/carbon/human/T = target
	if(T.IsSleeping())
		to_chat(owner, span_warning("[T] is already asleep!."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/hypno/InterceptClickOn(mob/living/user, params, atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(target_atom))
		return FALSE
	
	var/mob/living/carbon/human/T = target_atom
	user.visible_message(span_warning("[user] twirls their finger in a circular motion."),\
			span_warning("You twirl your finger in a circular motion."))


	var/protection = T.get_eye_protection()
	var/sleep_duration = 30 SECONDS
	switch(protection)
		if(1 to INFINITY)
			to_chat(user, span_vampirewarning("Your hypnotic powers are dampened by [T]'s eye protection."))
			sleep_duration = 10 SECONDS
		if(INFINITY)
			to_chat(user, span_vampirewarning("[T] is blind and is unaffected by hypnosis!"))
			return FALSE

	to_chat(T, span_boldwarning("Your knees suddenly feel heavy. Your body begins to sink to the floor."))
	to_chat(user, span_notice("[T] is now under your spell. In four seconds they will be rendered unconscious as long as they are within close range."))
	if(do_after(user, 4 SECONDS, T)) // 4 seconds...
		if(get_dist(user, T) <= 3)
			flash_color(T, flash_color="#472040", flash_time=3 SECONDS) // it's the vampires color!
			T.SetSleeping(sleep_duration)
			to_chat(user, span_warning("[T] has fallen asleep!"))
		else
			to_chat(T, span_notice("You feel a whole lot better now."))

	return TRUE

/datum/action/cooldown/spell/cloak
	name = "Cloak of Darkness"
	desc = "Toggles whether you are currently cloaking yourself in darkness."
	gain_desc = "You have gained the Cloak of Darkness ability which when toggled makes you near invisible in the shroud of darkness."
	button_icon_state = "cloak"
	button_icon = 'yogstation/icons/mob/vampire.dmi'
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"

	school = SCHOOL_CONJURATION

	cooldown_time = 1 SECONDS
	vamp_req = TRUE

/datum/action/cooldown/spell/cloak/New()
	. = ..()
	update_name()

/datum/action/cooldown/spell/cloak/proc/update_name()
	var/mob/living/user = owner
	if(!ishuman(user) || !is_vampire(user))
		return
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	name = "[initial(name)] ([V.iscloaking ? "Deactivate" : "Activate"])"

/datum/action/cooldown/spell/cloak/cast(mob/living/user)
	. = ..()
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return
	V.iscloaking = !V.iscloaking
	update_name()
	to_chat(user, span_notice("You will now be [V.iscloaking ? "hidden" : "seen"] in darkness."))

/datum/action/cooldown/spell/revive
	name = "Revive"
	gain_desc = "You have gained the ability to revive after death... However you can still be cremated/gibbed, and you will disintegrate if you're in the chapel and not yet strong enough!"
	desc = "Revives you, provided you are not in the chapel!"
	button_icon = 'yogstation/icons/mob/vampire.dmi'
	button_icon_state = "coffin"
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"

	school = SCHOOL_SANGUINE

	check_flags = NONE
	cooldown_time = 0 //no cooldown to the ability
	var/actual_cooldown = 1 MINUTES //cooldown applied when revived
	vamp_req = TRUE
	var/reviving = FALSE
	var/revive_timer

/datum/action/cooldown/spell/revive/cast(mob/living/user)
	. = ..()
	if(!is_vampire(user) || !isliving(user))
		return
	if(user.stat != DEAD)
		to_chat(user, span_notice("We aren't dead enough to do that yet!"))
		return
	if(user.reagents.has_reagent("holywater"))
		to_chat(user, span_danger("We cannot revive, holy water is in our system!"))
		return
	var/mob/living/L = user
	reviving = !reviving
	if(reviving)
		to_chat(L, span_notice("We begin to reanimate... this will take 1 minute."))
		deltimer(revive_timer)
		revive_timer = addtimer(CALLBACK(src, PROC_REF(revive), L), 1 MINUTES, TIMER_UNIQUE | TIMER_STOPPABLE)
	else
		to_chat(L, span_notice("We stop our reanimation."))
		deltimer(revive_timer)

/datum/action/cooldown/spell/revive/proc/revive(mob/living/user)
	if(istype(get_area(user.loc), /area/chapel))
		var/datum/antagonist/vampire/V = is_vampire(user)
		if(V && V.get_ability(/datum/vampire_passive/full)) //full blooded vampire doesn't get dusted if they try to res, it still doesn't work though
			to_chat(user, span_danger("The holy energies of this place prevent our revival!"))
			return
		else //yes yes, it's an else after a return, it just feels wrong without it though
			user.visible_message(span_warning("[user] disintegrates into dust!"), span_userdanger("Holy energy seeps into our very being, disintegrating us instantly!"), "You hear sizzling.")
			new /obj/effect/decal/remains/human(user.loc)
			user.dust()
			return
	if(user.stat != DEAD) //if they somehow revive before it goes off
		return
	StartCooldownSelf(actual_cooldown)//start the cooldown when the revive actually happens
	var/list/missing = user.get_missing_limbs()
	if(missing.len)
		playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)
		user.visible_message(span_warning("Shadowy matter takes the place of [user]'s missing limbs as they reform!"))
		user.regenerate_limbs()
		user.regenerate_organs()
	user.revive(full_heal = TRUE)
	user.visible_message(span_warning("[user] reanimates from death!"), span_notice("We get back up."))


/datum/action/cooldown/spell/aoe/screech
	name = "Chiropteran Screech (20)"
	desc = "An extremely loud shriek that stuns nearby humans and breaks windows as well."
	gain_desc = "You have gained the Chiropteran Screech ability which stuns anything with ears in a large radius and shatters glass in the process."
	button_icon_state = "reeee"
	button_icon = 'yogstation/icons/mob/vampire.dmi'
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"

	school = SCHOOL_SANGUINE

	aoe_radius = 4
	blood_used = 20
	vamp_req = TRUE

/datum/action/cooldown/spell/aoe/screech/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/atom/nearby_thing in hearers(aoe_radius, center))
		if(nearby_thing == owner || nearby_thing == center)
			continue

		if(!isliving(nearby_thing))
			continue

		things += nearby_thing

	return things

/datum/action/cooldown/spell/aoe/screech/cast(atom/cast_on)
	. = ..()
	owner.visible_message(span_warning("[owner] lets out an ear piercing shriek!"), span_warning("You let out a loud shriek."), span_warning("You hear a loud painful shriek!"))
	playsound(owner.loc, 'sound/effects/screech.ogg', 100, TRUE)
	for(var/obj/structure/window/W in view(aoe_radius, owner))
		W.take_damage(75)

/datum/action/cooldown/spell/aoe/screech/cast_on_thing_in_aoe(mob/living/target, mob/living/carbon/user)
	if(!target == user  || !is_vampire(target))
		if(ishuman(target) && target.soundbang_act(1, 0))
			var/mob/living/carbon/human/human_target = target
			to_chat(target, span_warning("<font size='3'><b>You hear a ear piercing shriek and your senses dull!</font></b>"))
			human_target.Knockdown(40)
			human_target.adjustEarDamage(0, 30)
			human_target.adjust_stutter(30 SECONDS)
			human_target.Paralyze(40)
			human_target.adjust_jitter(2.5 MINUTES)

/datum/action/cooldown/spell/bats
	name = "Summon Bats (30)"
	desc = "You summon a pair of space bats who attack nearby targets until they or their target is dead."
	gain_desc = "You have gained the Summon Bats ability."
	button_icon_state = "bats"
	button_icon = 'yogstation/icons/mob/vampire.dmi'
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"

	school = SCHOOL_CONJURATION

	cooldown_time = 2 MINUTES
	vamp_req = TRUE
	blood_used = 30
	var/num_bats = 2

/datum/action/cooldown/spell/bats/cast(mob/living/user)
	. = ..()
	var/list/turf/locs = new
	for(var/direction in GLOB.alldirs) //looking for bat spawns
		if(locs.len == num_bats) //we found 2 locations and thats all we need
			break
		var/turf/T = get_step(usr, direction) //getting a loc in that direction
		if(AStar(user, T, /turf/proc/Distance, 1, simulated_only = 0)) // if a path exists, so no dense objects in the way its valid salid
			locs += T

	// pad with player location
	for(var/i = locs.len + 1 to num_bats)
		locs += user.loc

	for(var/T in locs)
		new /mob/living/simple_animal/hostile/vampire_bat(T)

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/mistform
	name = "Mist Form (30)"
	gain_desc = "You have gained the Mist Form ability which allows you to take on the form of mist for a short period and pass over any obstacle in your path."
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"

	blood_used = 30
	vamp_req = TRUE

/datum/action/cooldown/spell/pointed/vampirize
	name = "Lilith's Pact (300)"
	desc = "You drain a victim's blood, and fill them with new blood, blessed by Lilith, turning them into a new vampire."
	gain_desc = "You have gained the ability to force someone, given time, to become a vampire."
	button_icon = 'yogstation/icons/mob/vampire.dmi'
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"
	button_icon_state = "oath"
	ranged_mousepointer = 'icons/effects/mouse_pointers/bite_target.dmi' //big win

	school = SCHOOL_SANGUINE

	blood_used = 300
	vamp_req = TRUE

/datum/action/cooldown/spell/pointed/vampirize/InterceptClickOn(mob/living/user, params, atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(target_atom))
		return
	var/mob/living/carbon/target = target_atom
	var/datum/antagonist/vampire/vamp = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(is_vampire(target))
		to_chat(user, span_warning("They're already a vampire!"))
		vamp.usable_blood += blood_used	// Refund cost
		return FALSE
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(user, span_warning("[target]'s mind is too strong!"))
		vamp.usable_blood += blood_used	// Refund cost
		return FALSE
	user.visible_message(span_warning("[user] latches onto [target]'s neck, pure dread eminating from them."), span_warning("You latch onto [target]'s neck, preparing to transfer your unholy blood to them."), span_warning("A dreadful feeling overcomes you"))
	target.reagents.add_reagent(/datum/reagent/medicine/salbutamol, 10) //incase you're choking the victim
	for(var/progress = 0, progress <= 3, progress++)
		switch(progress)
			if(1)
				to_chat(target, span_danger("Wicked shadows invade your sight, beckoning to you."))
				to_chat(user, span_notice("We begin to drain [target]'s blood in, so Lilith can bless it."))
			if(2)
				to_chat(target, span_danger("Demonic whispers fill your mind, and they become irressistible..."))
			if(3)
				to_chat(target, span_danger("The world blanks out, and you see a demo- no ange- demon- lil- glory- blessing... Lilith."))
				to_chat(user, span_notice("Excitement builds up in you as [target] sees the blessing of Lilith."))
		if(!do_after(user, 7 SECONDS, target))
			to_chat(user, span_danger("The pact has failed! [target] has not became a vampire."))
			to_chat(target, span_notice("The visions stop, and you relax."))
			vamp.usable_blood += blood_used	// Refund the cost
			return FALSE
	if(!QDELETED(user) && !QDELETED(target))
		to_chat(user, span_notice(". . ."))
		to_chat(target, span_italics("Come to me, child."))
		sleep(1 SECONDS)
		to_chat(target, span_italics("The world hasn't treated you well, has it?"))
		sleep(1.5 SECONDS)
		to_chat(target, span_italics("Strike fear into their hearts..."))
		to_chat(user, "<span class='notice italics bold'>They have signed the pact!</span>")
		to_chat(target, span_userdanger("You sign Lilith's Pact."))
		target.mind.store_memory("<B>[user] showed you the glory of Lilith. <I>You are not required to obey [user], however, you have gained a respect for them.</I></B>")
		target.Sleeping(600)
		target.blood_volume = 560
		add_vampire(target, FALSE)
		vamp.converted ++

	return TRUE

/datum/action/cooldown/spell/summon_coat
	name = "Summon Dracula Coat (100)"
	desc = "Allows you to summon a Vampire Coat providing passive usable blood restoration."
	gain_desc = "Now that you have reached full power, you can now pull a vampiric coat out of thin air!"
	button_icon = 'yogstation/icons/mob/vampire.dmi'
	button_icon_state = "coat"
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"

	school = SCHOOL_CONJURATION

	blood_used = 100
	vamp_req = TRUE

/datum/action/cooldown/spell/summon_coat/cast(mob/living/user)
	. = ..()
	if(!is_vampire(user) || !isliving(user))
		return
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return
	if(QDELETED(V.coat) || !V.coat)
		V.coat = new /obj/item/clothing/suit/draculacoat(user.loc)
	else if(get_dist(V.coat, user) > 1 || !(V.coat in user.get_all_contents()))
		V.coat.forceMove(user.loc)
	user.put_in_hands(V.coat)
	to_chat(user, span_notice("You summon your dracula coat."))

/datum/action/cooldown/spell/shapeshift/vampire
	name = "Bat Form (15)"
	gain_desc = "You now have the Bat Form ability, which allows you to turn into a bat (and back!)"
	desc = "Transform into a bat!"
	button_icon_state = "bat"
	button_icon = 'yogstation/icons/mob/vampire.dmi'
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"

	school = SCHOOL_TRANSMUTATION

	cooldown_time = 20 SECONDS
	die_with_shapeshifted_form = FALSE
	convert_damage_type = STAMINA
	blood_used = 15
	vamp_req = TRUE
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	possible_shapes = list(/mob/living/simple_animal/hostile/vampire_bat)

/datum/action/cooldown/spell/shapeshift/vampire/can_cast_spell()
	if(ishuman(owner))
		blood_used = 15
	else
		blood_used = 0
	return ..()
