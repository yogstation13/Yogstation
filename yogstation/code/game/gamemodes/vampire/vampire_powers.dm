/obj/effect/proc_holder/spell
	var/gain_desc
	var/blood_used = 0
	var/vamp_req = FALSE

/obj/effect/proc_holder/spell/cast_check(skipcharge = 0, mob/user = usr)
	if(vamp_req)
		if(!is_vampire(user))
			return FALSE
		var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
		if(!V)
			return FALSE
		if(V.usable_blood < blood_used)
			to_chat(user, span_warning("You do not have enough blood to cast this!"))
			return FALSE
	. = ..(skipcharge, user)

/obj/effect/proc_holder/spell/Initialize()
	. = ..()
	if(vamp_req)
		clothes_req = FALSE
		range = 1
		human_req = FALSE //so we can cast stuff while a bat, too


/obj/effect/proc_holder/spell/before_cast(list/targets)
	. = ..()
	if(vamp_req)
		// sanity check before we cast
		if(!is_vampire(usr))
			targets.Cut()
			return

		if(!blood_used)
			return

		// enforce blood
		var/datum/antagonist/vampire/vampire = usr.mind.has_antag_datum(/datum/antagonist/vampire)

		if(blood_used <= vampire.usable_blood)
			vampire.usable_blood -= blood_used
		else
			// stop!!
			targets.Cut()

		if(LAZYLEN(targets))
			to_chat(usr, span_notice("<b>You have [vampire.usable_blood] left to use.</b>"))


/obj/effect/proc_holder/spell/can_target(mob/living/target)
	. = ..()
	if(vamp_req && is_vampire(target))
		return FALSE
/datum/vampire_passive
	var/gain_desc

/datum/vampire_passive/New()
	..()
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

/obj/effect/proc_holder/spell/self/vampire_help
	name = "How to suck blood 101"
	desc = "Explains how the vampire blood sucking system works."
	action_icon_state = "bloodymaryglass"
	action_icon = 'icons/obj/drinks.dmi'
	action_background_icon_state = "bg_demon"
	charge_max = 0
	vamp_req = TRUE //YES YOU NEED TO BE A VAMPIRE TO KNOW HOW TO BE A VAMPIRE SHOCKING

/obj/effect/proc_holder/spell/self/vampire_help/cast(list/targets, mob/user = usr)
	to_chat(user, "<span class='notice'>You can consume blood from living, humanoid life by <b>punching their head while on the harm intent</b>. This <i>WILL</i> alert everyone who can see it as well as make a noise, which is generally hearable about <b>three meters away</b>. Note that you <b>cannot</b> draw blood from <b>catatonics or corpses</b>.\n\
			Your bloodsucking speed depends on grab strength, you can <i>stealthily</i> extract blood by initiating without a grab, and can suck more blood per cycle by <b>having a neck grab or stronger</b>. Both of these modify the amount of blood taken by 50%; less for stealth, more for strong grabs.</span>")

/obj/effect/proc_holder/spell/self/rejuvenate
	name = "Rejuvenate"
	desc= "Flush your system with spare blood to repair minor stamina damage to your body."
	action_icon_state = "rejuv"
	charge_max = 200
	stat_allowed = 1
	action_icon = 'yogstation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE

/obj/effect/proc_holder/spell/self/rejuvenate/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/U = user
	U.stuttering = 0

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
		sleep(0.75 SECONDS)


/obj/effect/proc_holder/spell/pointed/gaze
	name = "Vampiric Gaze"
	desc = "Paralyze your target with fear."
	charge_max = 300
	action_icon_state = "gaze"
	active_msg = "You prepare your vampiric gaze.</span>"
	deactive_msg = "You stop preparing your vampiric gaze.</span>"
	vamp_req = TRUE
	ranged_mousepointer = 'icons/effects/mouse_pointers/gaze_target.dmi'
	action_icon = 'yogstation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/pointed/gaze/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!target)
		return FALSE
	if(!ishuman(target))
		to_chat(user, span_warning("Gaze will not work on this being."))
		return FALSE
	var/mob/living/carbon/human/T = target

	if(T.stat == DEAD)
		to_chat(user,"<span class='warning'>You cannot gaze at corpses... \
			or maybe you could if you really wanted to.</span>")
		return FALSE

/obj/effect/proc_holder/spell/pointed/gaze/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
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


/obj/effect/proc_holder/spell/pointed/hypno
	name = "Hypnotize (20)"
	desc = "Knock out your target."
	charge_max = 300
	blood_used = 20
	action_icon_state = "hypnotize"
	active_msg = span_warning("You prepare your hypnosis technique.")
	deactive_msg = span_warning("You stop preparing your hypnosis.")
	vamp_req = TRUE
	ranged_mousepointer = 'icons/effects/mouse_pointers/hypnotize_target.dmi'
	action_icon = 'yogstation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/pointed/hypno/Click()
	if(!active)
		usr.visible_message(span_warning("[usr] twirls their finger in a circlular motion."),\
				span_warning("You twirl your finger in a circular motion."))
	..()

/obj/effect/proc_holder/spell/pointed/hypno/can_target(atom/target, mob/user, silent)
	if(!..())
		return FALSE
	if(!target)
		return FALSE
	if(!ishuman(target))
		to_chat(user, span_warning("Hypnotize will not work on this being."))
		return FALSE

	var/mob/living/carbon/human/T = target
	if(T.IsSleeping())
		to_chat(user, span_warning("[T] is already asleep!."))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/hypno/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
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

/obj/effect/proc_holder/spell/self/shapeshift
	name = "Shapeshift (50)"
	desc = "Changes your name and appearance at the cost of 50 blood and has a cooldown of 3 minutes."
	gain_desc = "You have gained the shapeshifting ability, at the cost of stored blood you can change your form permanently."
	action_icon_state = "genetic_poly"
	action_icon = 'yogstation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	blood_used = 50
	vamp_req = TRUE

/obj/effect/proc_holder/spell/self/shapeshift/cast(list/targets, mob/user = usr)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		user.visible_message(span_warning("[H] transforms!"))
		randomize_human(H)
	user.regenerate_icons()


/obj/effect/proc_holder/spell/self/cloak
	name = "Cloak of Darkness"
	desc = "Toggles whether you are currently cloaking yourself in darkness."
	gain_desc = "You have gained the Cloak of Darkness ability which when toggled makes you near invisible in the shroud of darkness."
	action_icon_state = "cloak"
	charge_max = 10
	action_icon = 'yogstation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE

/obj/effect/proc_holder/spell/self/cloak/Initialize()
	. = ..()
	update_name()

/obj/effect/proc_holder/spell/self/cloak/proc/update_name()
	var/mob/living/user = loc
	if(!ishuman(user) || !is_vampire(user))
		return
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	name = "[initial(name)] ([V.iscloaking ? "Deactivate" : "Activate"])"

/obj/effect/proc_holder/spell/self/cloak/cast(list/targets, mob/user = usr)
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return
	V.iscloaking = !V.iscloaking
	update_name()
	to_chat(user, span_notice("You will now be [V.iscloaking ? "hidden" : "seen"] in darkness."))


/obj/effect/proc_holder/spell/self/revive
	name = "Revive"
	gain_desc = "You have gained the ability to revive after death... However you can still be cremated/gibbed, and you will disintergrate if you're in the chapel!"
	desc = "Revives you, provided you are not in the chapel!"
	blood_used = 0
	stat_allowed = TRUE
	charge_max = 1000
	action_icon = 'yogstation/icons/mob/vampire.dmi'
	action_icon_state = "coffin"
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE

/obj/effect/proc_holder/spell/self/revive/cast(list/targets, mob/user = usr)
	if(!is_vampire(user) || !isliving(user))
		revert_cast()
		return
	if(user.stat != DEAD)
		to_chat(user, span_notice("We aren't dead enough to do that yet!"))
		revert_cast()
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
	addtimer(CALLBACK(src, /obj/effect/proc_holder/spell/self/revive.proc/revive, L), 600)

/obj/effect/proc_holder/spell/self/revive/proc/revive(mob/living/user)
	user.revive(full_heal = TRUE)
	user.visible_message(span_warning("[user] reanimates from death!"), span_notice("We get back up."))
	var/list/missing = user.get_missing_limbs()
	if(missing.len)
		playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)
		user.visible_message(span_warning("Shadowy matter takes the place of [user]'s missing limbs as they reform!"))
		user.regenerate_limbs(0, list(BODY_ZONE_HEAD))
		user.regenerate_organs()


/obj/effect/proc_holder/spell/targeted/disease
	name = "Diseased Touch (50)"
	desc = "Touches your victim with infected blood giving them Grave Fever, which will, left untreated, causes toxic building and frequent collapsing."
	gain_desc = "You have gained the Diseased Touch ability which causes those you touch to become weak unless treated medically."
	action_icon_state = "disease"
	action_icon = 'yogstation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	blood_used = 50
	vamp_req = TRUE

/obj/effect/proc_holder/spell/targeted/disease/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/target in targets)
		to_chat(user, span_warning("You stealthily infect [target] with your diseased touch."))
		target.help_shake_act(user)
		if(is_vampire(target))
			to_chat(user, span_warning("They seem to be unaffected."))
			continue
		var/datum/disease/D = new /datum/disease/vampire
		target.ForceContractDisease(D)


/obj/effect/proc_holder/spell/self/screech
	name = "Chiropteran Screech (20)"
	desc = "An extremely loud shriek that stuns nearby humans and breaks windows as well."
	gain_desc = "You have gained the Chiropteran Screech ability which stuns anything with ears in a large radius and shatters glass in the process."
	action_icon_state = "reeee"
	action_icon = 'yogstation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	blood_used = 20
	vamp_req = TRUE

/obj/effect/proc_holder/spell/self/screech/cast(list/targets, mob/user = usr)
	user.visible_message(span_warning("[user] lets out an ear piercing shriek!"), span_warning("You let out a loud shriek."), span_warning("You hear a loud painful shriek!"))
	for(var/mob/living/carbon/C in hearers(4))
		if(!C == user  || !is_vampire(C))
			if(ishuman(C) && C.soundbang_act(1, 0))
				to_chat(C, span_warning("<font size='3'><b>You hear a ear piercing shriek and your senses dull!</font></b>"))
				C.Knockdown(40)
				C.adjustEarDamage(0, 30)
				C.stuttering = 30
				C.Paralyze(40)
				C.Jitter(150)
	for(var/obj/structure/window/W in view(4))
		W.take_damage(75)
	playsound(user.loc, 'sound/effects/screech.ogg', 100, 1)


/obj/effect/proc_holder/spell/bats
	name = "Summon Bats (30)"
	desc = "You summon a pair of space bats who attack nearby targets until they or their target is dead."
	gain_desc = "You have gained the Summon Bats ability."
	action_icon_state = "bats"
	action_icon = 'yogstation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	charge_max = 1200
	vamp_req = TRUE
	blood_used = 30
	var/num_bats = 2

/obj/effect/proc_holder/spell/bats/choose_targets(mob/user = usr)
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

	perform(locs, user = user)

/obj/effect/proc_holder/spell/bats/cast(list/targets, mob/user = usr)
	for(var/T in targets)
		new /mob/living/simple_animal/hostile/vampire_bat(T)


/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/mistform
	name = "Mist Form (30)"
	gain_desc = "You have gained the Mist Form ability which allows you to take on the form of mist for a short period and pass over any obstacle in your path."
	blood_used = 30
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/mistform/Initialize()
	. = ..()
	range = -1
	addtimer(VARSET_CALLBACK(src, range, -1), 10) //Avoid fuckery


/obj/effect/proc_holder/spell/targeted/vampirize
	name = "Lilith's Pact (300)"
	desc = "You drain a victim's blood, and fill them with new blood, blessed by Lilith, turning them into a new vampire."
	gain_desc = "You have gained the ability to force someone, given time, to become a vampire."
	action_icon = 'yogstation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	action_icon_state = "oath"
	blood_used = 300
	vamp_req = TRUE

/obj/effect/proc_holder/spell/targeted/vampirize/cast(list/targets, mob/user = usr)
	var/datum/antagonist/vampire/vamp = user.mind.has_antag_datum(/datum/antagonist/vampire)
	for(var/mob/living/carbon/target in targets)
		if(is_vampire(target))
			to_chat(user, span_warning("They're already a vampire!"))
			vamp.usable_blood += blood_used	// Refund cost
			continue
		if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
			to_chat(user, span_warning("[target]'s mind is too strong!"))
			vamp.usable_blood += blood_used	// Refund cost
			continue
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
				return
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

/obj/effect/proc_holder/spell/self/summon_coat
	name = "Summon Dracula Coat (100)"
	desc = "Allows you to summon a Vampire Coat providing passive usable blood restoration when your usable blood is very low."
	gain_desc = "Now that you have reached full power, you can now pull a vampiric coat out of thin air!"
	blood_used = 100
	action_icon = 'yogstation/icons/mob/vampire.dmi'
	action_icon_state = "coat"
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE

/obj/effect/proc_holder/spell/self/summon_coat/cast(list/targets, mob/user = usr)
	if(!is_vampire(user) || !isliving(user))
		revert_cast()
		return
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return
	if(QDELETED(V.coat) || !V.coat)
		V.coat = new /obj/item/clothing/suit/draculacoat(user.loc)
	else if(get_dist(V.coat, user) > 1 || !(V.coat in user.GetAllContents()))
		V.coat.forceMove(user.loc)
	user.put_in_hands(V.coat)
	to_chat(user, span_notice("You summon your dracula coat."))


/obj/effect/proc_holder/spell/self/batform
	name = "Bat Form (15)"
	gain_desc = "You now have the Bat Form ability, which allows you to turn into a bat (and back!)"
	desc = "Transform into a bat!"
	action_icon_state = "bat"
	charge_max = 200
	blood_used = 0 //this is only 0 so we can do our own custom checks
	action_icon = 'yogstation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE
	var/mob/living/simple_animal/hostile/vampire_bat/bat

/obj/effect/proc_holder/spell/self/batform/cast(list/targets, mob/user = usr)
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return FALSE
	if(!bat || bat.stat == DEAD)
		if(V.usable_blood < 15)
			to_chat(user, span_warning("You do not have enough blood to cast this!"))
			return FALSE
		bat = new /mob/living/simple_animal/hostile/vampire_bat(user.loc)
		user.forceMove(bat)
		bat.controller = user
		user.status_flags |= GODMODE
		user.mind.transfer_to(bat)
		charge_counter = charge_max //so you don't need to wait 20 seconds to turn BACK.
		recharging = FALSE
		action.UpdateButtonIcon()
	else
		bat.controller.forceMove(bat.loc)
		bat.controller.status_flags &= ~GODMODE
		bat.mind.transfer_to(bat.controller)
		bat.controller = null //just so we don't accidently trigger the death() thing
		qdel(bat)
