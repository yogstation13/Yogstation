/obj/item/melee/sledgehammer
	name = "sledgehammer"
	desc = "An hefty tool used for smashing apart windows, machinery, and other structures. Printers beware."
	icon = 'icons/obj/weapons/hammer.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/back.dmi'
	icon_state = "sledgehammer"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	force = 5 /// The weapon requires two hands
	throwforce = 12
	throw_range = 3 /// Doesn't throw very far
	demolition_mod = 6 // BREAK THINGS
	armour_penetration = -20
	hitsound = 'sound/weapons/smash.ogg' /// Hitsound when thrown at someone
	attack_verb_continuous = list("slams", "crushes", "smashes", "flattens", "pounds")
	attack_verb_simple = list("slam", "crush", "smash", "flatten", "pound")
	custom_materials = list(/datum/material/iron=6000)
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	wound_bonus = -15
	bare_wound_bonus = 15

/obj/item/melee/sledgehammer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_wielded = 10, wield_callback = CALLBACK(src, PROC_REF(on_wield)), unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), require_twohands = TRUE)

/obj/item/melee/sledgehammer/proc/on_wield(atom/source, mob/living/user)
	hitsound = "swing_hit"

/obj/item/melee/sledgehammer/proc/on_unwield(atom/source, mob/living/user)
	hitsound = initial(hitsound)

/obj/item/melee/sledgehammer/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_WIELDED) && user)
		/// This will already do low damage, so it doesn't need to be intercepted earlier
		to_chat(user, span_danger("\The [src] is too heavy to attack effectively without being wielded!"))
		return
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/humantarget = target
		if(!HAS_TRAIT(target, TRAIT_SPLEENLESS_METABOLISM) && humantarget.get_organ_slot(ORGAN_SLOT_SPLEEN) && !isnull(humantarget.dna.species.mutantspleen))
			var/obj/item/organ/internal/spleen/target_spleen = humantarget.get_organ_slot(ORGAN_SLOT_SPLEEN)
			target_spleen.apply_organ_damage(5)
	if(!proximity_flag)
		return

	if(target.uses_integrity)
		if(!QDELETED(target))
			if(istype(get_area(target), /area/shipbreak))
				if(isstructure(target))
					target.take_damage(force * demolition_mod, BRUTE, MELEE, FALSE, null, 20) // Breaks "structures pretty good"
				if(ismachinery(target))
					target.take_damage(force * demolition_mod, BRUTE, MELEE, FALSE, null, 20) // A luddites friend, Sledghammer good at break machine
			playsound(src, 'sound/effects/bang.ogg', 40, 1)

/obj/item/melee/sledgehammer/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, gentle = FALSE, quickstart)
	. = ..()
	if(iscarbon(thrower))
		var/mob/living/carbon/C = thrower
		C.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/sledgehammer_thrown_stagger, update=TRUE)
		addtimer(CALLBACK(C, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/status_effect/sledgehammer_thrown_stagger), 4 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
		to_chat(target, span_danger("You are staggered from throwing such a heavy object!"))
