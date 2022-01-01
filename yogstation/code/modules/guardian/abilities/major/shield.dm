GLOBAL_LIST_INIT(guardian_shield_traits, list(
	TRAIT_RESISTHEAT, TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE, TRAIT_BOMBIMMUNE, TRAIT_RADIMMUNE,
	TRAIT_NODISMEMBER, TRAIT_NOFIRE, TRAIT_NOINTERACT, TRAIT_NOHUNGER, TRAIT_NOBREATH, TRAIT_NOCRITDAMAGE))
GLOBAL_LIST_INIT(guardian_shield_length, list(
	1 = 15 SECONDS,
	2 = 30 SECONDS,
	3 = 1 MINUTES,
	4 = 2 MINUTES,
	5 = 5 MINUTES
))

/datum/guardian_ability/major/shield
	name = "Shield"
	desc = "The guardian can project a shield around its master, giving them nigh-absolute protection at the cost of immobilizing them."
	cost = 4
	spell_type = /obj/effect/proc_holder/spell/self/guardian_shield
	var/list/shields = list()

/datum/guardian_ability/major/shield/Remove()
	. = ..()
	QDEL_LIST(shields)

/datum/guardian_ability/major/shield/Recall()
	QDEL_LIST(shields)

/obj/effect/proc_holder/spell/self/guardian_shield
	name = "Activate Shield"
	desc = "Create an inpenetrable shield around you and your master."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 90 SECONDS

/obj/effect/proc_holder/spell/self/guardian_shield/cast(list/targets, mob/user)
	if(!isguardian(user))
		revert_cast()
		return
	var/mob/living/simple_animal/hostile/guardian/guardian = user
	if (!guardian.is_deployed())
		to_chat(guardian, span_boldwarning("You must be manifested to use this ability!"))
		revert_cast()
		return
	var/datum/guardian_ability/major/shield/ability = guardian.has_ability(/datum/guardian_ability/major/shield)
	var/mob/living/master = guardian.summoner?.current
	if (!ability || !master)
		revert_cast()
		return
	if (LAZYLEN(ability.shields))
		QDEL_LIST(ability.shields)
		return
	for (var/G in master.hasparasites())
		var/mob/living/simple_animal/hostile/guardian/other_guardian = G
		if (guardian != other_guardian)
			other_guardian.Recall()
	var/obj/effect/shielded_mob/shield = new(master.loc, master, guardian.namedatum.color, GLOB.guardian_shield_length[guardian.stats.potential], guardian, CALLBACK(src, .proc/done))
	guardian.forceMove(shield)
	charge_counter = charge_max

/obj/effect/proc_holder/spell/self/guardian_shield/proc/done()
	charge_counter = 0
	start_recharge()
	updateButtonIcon()

/obj/effect/shielded_mob
	anchored = TRUE
	density = TRUE
	var/mob/living/user
	var/mutable_appearance/overlay
	var/mutable_appearance/extra_overlay
	var/timer_id
	var/datum/callback/on_done

/obj/effect/shielded_mob/Initialize(mapload, mob/living/user, color, time_limit, mob/living/extra, datum/callback/on_done)
	. = ..()
	overlay = mutable_appearance(icon = 'icons/effects/effects.dmi', icon_state = "shield-grey", layer = ABOVE_MOB_LAYER)
	overlay.color = color
	if (extra)
		extra.setDir(user.dir)
		extra_overlay = mutable_appearance(getFlatIcon(extra, user.dir))
		extra_overlay.alpha = 128
		switch(extra.dir)
			if (NORTH)
				extra_overlay.pixel_y = -16
				extra_overlay.layer = user.layer + 0.1
			if (SOUTH)
				extra_overlay.pixel_y = 16
				extra_overlay.layer = user.layer - 0.1
			if (EAST)
				extra_overlay.pixel_x = -16
				extra_overlay.layer = user.layer
			if (WEST)
				extra_overlay.pixel_x = 16
				extra_overlay.layer = user.layer
	setup(user)
	if (time_limit)
		timer_id = QDEL_IN(src, time_limit)
	if (on_done)
		src.on_done = on_done

/obj/effect/shielded_mob/Destroy()
	leave()
	return ..()

/obj/effect/shielded_mob/examine(mob/user)
	. = src.user.examine(user)
	. += span_holoparasite(span_bold("A powerful shield is protecting [src.user.p_them()]!"))

/obj/effect/shielded_mob/proc/setup(mob/living/new_user)
	user = new_user
	user.status_flags |= GODMODE
	user.visible_message(span_warning("A protective shield forms around [user]!"), span_notice("A shield forms around you, protecting you from harm!"))
	setDir(user.dir)
	appearance = user.appearance
	if (extra_overlay)
		add_overlay(extra_overlay)
	add_overlay(overlay)
	user.forceMove(src)
	for(var/trait in GLOB.guardian_shield_traits)
		ADD_TRAIT(user, trait, GUARDIAN_TRAIT)

/obj/effect/shielded_mob/proc/leave()
	if (timer_id)
		deltimer(timer_id)
	user.status_flags &= ~GODMODE
	for(var/trait in GLOB.guardian_shield_traits)
		REMOVE_TRAIT(user, trait, GUARDIAN_TRAIT)
	for (var/atom/movable/thingy in contents)
		thingy.forceMove(drop_location())
	user.visible_message(span_warning("The protective shield around [user] fades."), span_notice("The protective shield around you fades."))
	if (on_done)
		on_done.Invoke()

/obj/effect/shielded_mob/ex_act()
	return

/obj/effect/shielded_mob/emp_act()
	return

/obj/effect/shielded_mob/rad_act()
	return

/obj/effect/shielded_mob/fire_act()
	return

/obj/effect/shielded_mob/bullet_act(obj/item/projectile/P)
	return BULLET_ACT_BLOCK

/obj/effect/shielded_mob/relaymove(mob/user)
	to_chat(user, span_notice("You are immobile while protected by the shield!"))
