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
		gain_desc = "You have gained \the [src] ability."


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/vampire_passive/nostealth
	gain_desc = "You are no longer able to conceal yourself while sucking blood."

/datum/vampire_passive/regen
	gain_desc = "Your rejuvenation abilities have improved and will now heal you over time when used."

/datum/vampire_passive/vision
	gain_desc = "Your vampiric vision has improved."

/datum/vampire_passive/full
	gain_desc = "You have reached your full potential and are no longer weak to the effects of anything holy and your vision has been improved greatly."

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/action/cooldown/spell/vampire_help
	name = "How to suck blood 101"
	desc = "Explains how the vampire blood sucking system works."
	button_icon_state = "bloodymaryglass"
	button_icon = 'icons/obj/drinks.dmi'
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"

	school = SCHOOL_SANGUINE

	vamp_req = TRUE //YES YOU NEED TO BE A VAMPIRE TO KNOW HOW TO BE A VAMPIRE SHOCKING

/datum/action/cooldown/spell/vampire_help/cast(mob/living/user)
	. = ..()
	to_chat(user, "<span class='notice'>You can consume blood from living, humanoid life by <b>punching their head while on the harm intent</b>. This <i>WILL</i> alert everyone who can see it as well as make a noise, which is generally hearable about <b>three meters away</b>. Note that you <b>cannot</b> draw blood from <b>catatonics or corpses</b>.\n\
			Your bloodsucking speed depends on grab strength, you can <i>stealthily</i> extract blood by initiating without a grab, and can suck more blood per cycle by <b>having a neck grab or stronger</b>. Both of these modify the amount of blood taken by 50%; less for stealth, more for strong grabs.</span>")

	return TRUE

/datum/action/cooldown/spell/rejuvenate
	name = "Rejuvenate"
	desc= "Flush your system with spare blood to repair minor stamina damage to your body."
	button_icon_state = "rejuv"
	button_icon = 'yogstation/icons/mob/vampire.dmi'
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"

	school = SCHOOL_RESTORATION

	cooldown_time = 20 SECONDS
	vamp_req = TRUE

/datum/action/cooldown/spell/rejuvenate/cast(mob/living/user)
	. = ..()
	var/mob/living/carbon/U = user
	U.remove_status_effect(/datum/status_effect/speech/stutter)

	var/datum/antagonist/vampire/V = U.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V) //sanity check
		return
	for(var/i = 1 to 5)
		U.adjustStaminaLoss(-50)
		if(V.get_ability(/datum/vampire_passive/regen))
			U.adjustBruteLoss(-1)
			U.adjustOxyLoss(-2.5)
			U.adjustToxLoss(-1, TRUE, TRUE)
			U.adjustFireLoss(-1)

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
	var/mob/living/target = target_atom
	var/mob/living/carbon/human/T = target
	user.visible_message(span_warning("[user]'s eyes flash red."),\
					span_warning("[user]'s eyes flash red."))
	if(ishuman(target))
		var/obj/item/clothing/glasses/G = T.glasses
		if(G)
			if(G.flash_protect > 0)
				to_chat(user,span_warning("[T] has protective sunglasses on!"))
				to_chat(target, span_warning("[user]'s paralyzing gaze is blocked by your [G]!"))
				return
		var/obj/item/clothing/mask/M = T.wear_mask
		if(M)
			if(M.flash_protect > 0)
				to_chat(user,span_warning("[T]'s mask is covering their eyes!"))
				to_chat(target,span_warning("[user]'s paralyzing gaze is blocked by your [M]!"))
				return
		var/obj/item/clothing/head/H = T.head
		if(H)
			if(H.flash_protect > 0)
				to_chat(user, span_vampirewarning("[T]'s helmet is covering their eyes!"))
				to_chat(target, span_warning("[user]'s paralyzing gaze is blocked by [H]!"))
				return
		to_chat(target,span_warning("You are paralyzed with fear!"))
		to_chat(user,span_notice("You paralyze [T]."))
		T.Stun(50)

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
	user.visible_message(span_warning("[user] twirls their finger in a circlular motion."),\
			span_warning("You twirl your finger in a circular motion."))
	var/mob/living/target = target_atom
	var/mob/living/carbon/human/T = target
	user.visible_message(span_warning("[user]'s eyes flash red."),\
					span_warning("[user]'s eyes flash red."))
	if(T)
		var/obj/item/clothing/glasses/G = T.glasses
		if(G)
			if(G.flash_protect > 0)
				to_chat(user, span_warning("[T] has protective sunglasses on!"))
				to_chat(target, span_warning("[user]'s paralyzing gaze is blocked by [G]!"))
				return
		var/obj/item/clothing/mask/M = T.wear_mask
		if(M)
			if(M.flash_protect > 0)
				to_chat(user, span_vampirewarning("[T]'s mask is covering their eyes!"))
				to_chat(target, span_warning("[user]'s paralyzing gaze is blocked by [M]!"))
				return
		var/obj/item/clothing/head/H = T.head
		if(H)
			if(H.flash_protect > 0)
				to_chat(user, span_vampirewarning("[T]'s helmet is covering their eyes!"))
				to_chat(target, span_warning("[user]'s paralyzing gaze is blocked by [H]!"))
				return
	to_chat(target, span_boldwarning("Your knees suddenly feel heavy. Your body begins to sink to the floor."))
	to_chat(user, span_notice("[target] is now under your spell. In four seconds they will be rendered unconscious as long as they are within close range."))
	if(do_mob(user, target, 40, TRUE)) // 4 seconds...
		if(get_dist(user, T) <= 3)
			flash_color(T, flash_color="#472040", flash_time=30) // it's the vampires color!
			T.SetSleeping(300)
			to_chat(user, span_warning("[T] has fallen asleep!"))
		else
			to_chat(T, span_notice("You feel a whole lot better now."))

	return TRUE

/datum/action/cooldown/spell/appearanceshift
	name = "Shapeshift (50)"
	desc = "Changes your name and appearance at the cost of 50 blood and has a cooldown of 3 minutes."
	gain_desc = "You have gained the shapeshifting ability, at the cost of stored blood you can change your form permanently."
	button_icon_state = "genetic_poly"
	button_icon = 'yogstation/icons/mob/vampire.dmi'
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"

	school = SCHOOL_TRANSMUTATION

	blood_used = 50
	vamp_req = TRUE

/datum/action/cooldown/spell/appearanceshift/cast(mob/living/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		user.visible_message(span_warning("[H] transforms!"))
		randomize_human(H)
	user.regenerate_icons()

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
	gain_desc = "You have gained the ability to revive after death... However you can still be cremated/gibbed, and you will disintergrate if you're in the chapel!"
	desc = "Revives you, provided you are not in the chapel!"
	button_icon = 'yogstation/icons/mob/vampire.dmi'
	check_flags = NONE
	button_icon_state = "coffin"
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"
	check_flags = NONE

	school = SCHOOL_SANGUINE

	cooldown_time = 100 SECONDS
	vamp_req = TRUE

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
	if(istype(get_area(L.loc), /area/chapel))
		L.visible_message(span_warning("[L] disintergrates into dust!"), span_userdanger("Holy energy seeps into our very being, disintergrating us instantly!"), "You hear sizzling.")
		new /obj/effect/decal/remains/human(L.loc)
		L.dust()
	to_chat(L, span_notice("We begin to reanimate... this will take 1 minute."))
	addtimer(CALLBACK(src, PROC_REF(revive), L), 1 MINUTES)

/datum/action/cooldown/spell/revive/proc/revive(mob/living/user)
	var/list/missing = user.get_missing_limbs()
	if(missing.len)
		playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)
		user.visible_message(span_warning("Shadowy matter takes the place of [user]'s missing limbs as they reform!"))
		user.regenerate_limbs()
		user.regenerate_organs()
	user.revive(full_heal = TRUE)
	user.visible_message(span_warning("[user] reanimates from death!"), span_notice("We get back up."))


/datum/action/cooldown/spell/pointed/disease
	name = "Diseased Touch (50)"
	desc = "Touches your victim with infected blood giving them Grave Fever, which will, left untreated, causes toxic building and frequent collapsing."
	gain_desc = "You have gained the Diseased Touch ability which causes those you touch to become weak unless treated medically."
	button_icon_state = "disease"
	button_icon = 'yogstation/icons/mob/vampire.dmi'
	background_icon_state = "bg_vampire"
	overlay_icon_state = "bg_vampire_border"

	school = SCHOOL_SANGUINE

	blood_used = 50
	vamp_req = TRUE

/datum/action/cooldown/spell/pointed/disease/InterceptClickOn(mob/living/user, params, atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(target_atom))
		return FALSE
	if(is_vampire(target_atom))
		to_chat(user, span_warning("They seem to be unaffected."))
		return FALSE

	var/mob/living/carbon/target = target_atom
	to_chat(user, span_warning("You stealthily infect [target] with your diseased touch."))
	target.help_shake_act(user)
	var/datum/disease/D = new /datum/disease/vampire
	target.ForceContractDisease(D)

	return TRUE


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

/datum/action/cooldown/spell/aoe/screech/cast_on_thing_in_aoe(mob/living/target, mob/living/carbon/user)
	user.visible_message(span_warning("[user] lets out an ear piercing shriek!"), span_warning("You let out a loud shriek."), span_warning("You hear a loud painful shriek!"))
	if(!target == user  || !is_vampire(target))
		if(ishuman(target) && target.soundbang_act(1, 0))
			var/mob/living/carbon/human/human_target = target
			to_chat(target, span_warning("<font size='3'><b>You hear a ear piercing shriek and your senses dull!</font></b>"))
			human_target.Knockdown(40)
			human_target.adjustEarDamage(0, 30)
			human_target.adjust_stutter(30 SECONDS)
			human_target.Paralyze(40)
			human_target.adjust_jitter(2.5 MINUTES)
	for(var/obj/structure/window/W in view(aoe_radius, user))
		W.take_damage(75)
	playsound(user.loc, 'sound/effects/screech.ogg', 100, TRUE)

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
		if(!do_mob(user, target, 70))
			to_chat(user, span_danger("The pact has failed! [target] has not became a vampire."))
			to_chat(target, span_notice("The visions stop, and you relax."))
			vamp.usable_blood += blood_used / 2	// Refund half the cost
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
	desc = "Allows you to summon a Vampire Coat providing passive usable blood restoration when your usable blood is very low."
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
	possible_shapes = list(/mob/living/simple_animal/hostile/vampire_bat)

/datum/action/cooldown/spell/shapeshift/vampire/can_cast_spell()
	if(ishuman(owner))
		blood_used = 15
	else
		blood_used = 0
	return ..()
