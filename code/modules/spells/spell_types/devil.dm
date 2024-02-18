/datum/action/cooldown/spell/conjure_item/summon_pitchfork
	name = "Summon Pitchfork"
	desc = "A devil's weapon of choice.  Use this to summon/unsummon your pitchfork."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "pitchfork"
	background_icon_state = "bg_demon"

	school = SCHOOL_CONJURATION
	invocation_type = INVOCATION_NONE

	item_type = /obj/item/pitchfork/demonic
	cooldown_time = 15 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/conjure_item/summon_pitchfork/greater
	item_type = /obj/item/pitchfork/demonic/greater

/datum/action/cooldown/spell/conjure_item/summon_pitchfork/ascended
	item_type = /obj/item/pitchfork/demonic/ascended

/datum/action/cooldown/spell/conjure_item/violin
	name = "Summon golden violin"
	desc = "A devil's instrument of choice. \n\
		Use this to summon/unsummon your golden violin."
	button_icon_state = "golden_violin"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_demon"

	invocation = "I aint have this much fun since Georgia."
	invocation_type = INVOCATION_WHISPER

	item_type = /obj/item/instrument/violin/golden
	spell_requirements = NONE

/datum/action/cooldown/spell/pointed/summon_contract
	name = "Summon infernal contract"
	desc = "Skip making a contract by hand, just do it by magic."
	button_icon_state = "spell_default"
	background_icon_state = "bg_demon"

	school = SCHOOL_CONJURATION
	invocation = "Just sign on the dotted line."
	invocation_type = INVOCATION_WHISPER

	cast_range = 5
	cooldown_time = 15 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/pointed/summon_contract/InterceptClickOn(mob/living/user, params, atom/target)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/carbon_target = target
	if(!carbon_target.mind)
		to_chat(user, span_notice("[carbon_target] seems to not be sentient. \
								You cannot summon a contract for [carbon_target.p_them()]."))
		return FALSE
	if(carbon_target.stat == DEAD)
		if(carbon_target.dropItemToGround(carbon_target.get_active_held_item()))
			var/obj/item/paper/contract/infernal/revive/contract = new(owner.loc, carbon_target.mind, owner.mind)
			user.put_in_hands(contract)
			return TRUE
		return FALSE

	var/obj/item/paper/contract/infernal/contract  // = new(user.loc, C.mind, contractType, user.mind)
	var/contractTypeName = tgui_input_list(owner, "What type of contract?", "Devilish", list("Power", "Wealth", "Prestige", "Magic", "Knowledge", "Friendship"))
	switch(contractTypeName)
		if("Power")
			contract = new /obj/item/paper/contract/infernal/power(carbon_target.loc, carbon_target.mind, owner.mind)
		if("Wealth")
			contract = new /obj/item/paper/contract/infernal/wealth(carbon_target.loc, carbon_target.mind, owner.mind)
		if("Prestige")
			contract = new /obj/item/paper/contract/infernal/prestige(carbon_target.loc, carbon_target.mind, owner.mind)
		if("Magic")
			contract = new /obj/item/paper/contract/infernal/magic(carbon_target.loc, carbon_target.mind, owner.mind)
		if("Knowledge")
			contract = new /obj/item/paper/contract/infernal/knowledge(carbon_target.loc, carbon_target.mind, owner.mind)
		if("Friendship")
			contract = new /obj/item/paper/contract/infernal/friend(carbon_target.loc, carbon_target.mind, owner.mind)
	carbon_target.put_in_hands(contract)

	return TRUE

/datum/action/cooldown/spell/pointed/projectile/fireball/hellish
	name = "Hellfire"
	desc = "This spell launches hellfire at the target."
	background_icon_state = "bg_demon"

	school = SCHOOL_EVOCATION
	invocation = "Your very soul will catch fire!"
	invocation_type = INVOCATION_SHOUT

	cooldown_time = 6 SECONDS
	cast_range = 2
	spell_requirements = NONE

	projectile_type = /obj/projectile/magic/fireball/infernal

/datum/action/cooldown/spell/jaunt/infernal_jaunt
	name = "Infernal Jaunt"
	desc = "Use hellfire to phase out of existence."
	button_icon_state = "jaunt"
	background_icon_state = "bg_demon"

	cooldown_time = 20 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/jaunt/infernal_jaunt/cast(mob/living/user)
	. = ..()
	if(!.)
		return FALSE
	if(istype(user))
		if(is_jaunting(user))
			if(valid_location(user))
				to_chat(user, span_warning("You are now phasing in."))
				if(do_after(user, 15 SECONDS))
					if(valid_location(user))
						user.infernalphasein()
					else
						to_chat(user, span_warning("You are no longer near a potential signer."))

			else
				to_chat(user, span_warning("You can only re-appear near a potential signer."))
				return ..()
		else
			user.notransform = TRUE
			user.fakefire()
			to_chat(src, span_warning("You begin to phase back into sinful flames."))
			if(do_after(user, 15 SECONDS))
				user.infernalphaseout()
			else
				to_chat(user, span_warning("You must remain still while exiting."))
				user.notransform = FALSE
				user.fakefireextinguish()
		return

	return TRUE

/datum/action/cooldown/spell/jaunt/infernal_jaunt/proc/valid_location(mob/living/user = usr)
	if(istype(get_area(user), /area/shuttle/)) // Can always phase in in a shuttle.
		return TRUE
	else
		for(var/mob/living/C in orange(2, get_turf(user))) //Can also phase in when nearby a potential buyer.
			if (C.owns_soul())
				return TRUE
	return FALSE

/mob/living/proc/infernalphaseout()
	dust_animation()
	spawn_dust()
	visible_message(span_warning("[src] disappears in a flashfire!"))
	playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 100, 1, -1)
	var/obj/effect/dummy/phased_mob/holder = new /obj/effect/dummy/phased_mob(loc)
	extinguish_mob()
	forceMove(holder)
	src.holder = holder
	notransform = FALSE
	fakefireextinguish()

/mob/living/proc/infernalphasein()
	if(notransform)
		to_chat(src, span_warning("You're too busy to jaunt in."))
		return FALSE
	fakefire()
	forceMove(drop_location())
	client.set_eye(src)
	visible_message(span_warning("<B>[src] appears in a fiery blaze!</B>"))
	playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 100, 1, -1)
	addtimer(CALLBACK(src, PROC_REF(fakefireextinguish)), 15, TIMER_UNIQUE)

/datum/action/cooldown/spell/aoe/sintouch
	name = "Sin Touch"
	desc = "Subtly encourage someone to sin."
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "sintouch"
	background_icon_state = "bg_demon"

	invocation = "TASTE SIN AND INDULGE!!"
	invocation_type = INVOCATION_SHOUT

	cooldown_time = 3 MINUTES
	aoe_radius = 2
	max_targets = 3
	spell_requirements = NONE

/datum/action/cooldown/spell/aoe/sintouch/ascended
	name = "Greater Sin Touch"
	cooldown_time = 10 SECONDS
	aoe_radius = 7
	max_targets = 10

/datum/action/cooldown/spell/aoe/sintouch/cast_on_thing_in_aoe(atom/target, atom/caster)
	if(!iscarbon(target))
		return
	var/mob/living/carbon/target_carbon = target
	if(!target_carbon.mind)
		return
	if(target_carbon.mind.has_antag_datum(/datum/antagonist/sintouched))
		return
	if(target_carbon.can_block_magic(MAGIC_RESISTANCE_HOLY))
		return
	target_carbon.mind.add_antag_datum(/datum/antagonist/sintouched)
	target_carbon.Paralyze(40 SECONDS)

/datum/action/cooldown/spell/summon_dancefloor
	name = "Summon Dancefloor"
	desc = "When what a Devil really needs is funk."

	school = SCHOOL_CONJURATION

	cooldown_time = 5 SECONDS //so the smoke can't be spammed
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "funk"
	background_icon_state = "bg_demon"
	spell_requirements = NONE

	var/list/dancefloor_turfs
	var/list/dancefloor_turfs_types
	var/dancefloor_exists = FALSE
	var/datum/effect_system/fluid_spread/smoke/transparent/dancefloor_devil/smoke


/datum/action/cooldown/spell/summon_dancefloor/cast(mob/living/carbon/user)
	. = ..()
	if(!.)
		return FALSE
	LAZYINITLIST(dancefloor_turfs)
	LAZYINITLIST(dancefloor_turfs_types)

	if(!smoke)
		smoke = new()
	smoke.set_up(0, location = get_turf(user))
	smoke.start()

	if(dancefloor_exists)
		dancefloor_exists = FALSE
		for(var/i in 1 to dancefloor_turfs.len)
			var/turf/T = dancefloor_turfs[i]
			T.ChangeTurf(dancefloor_turfs_types[i], flags = CHANGETURF_INHERIT_AIR)
	else
		var/list/funky_turfs = RANGE_TURFS(1, user)
		for(var/turf/closed/solid in funky_turfs)
			to_chat(user, span_warning("You're too close to a wall."))
			return
		dancefloor_exists = TRUE
		var/i = 1
		dancefloor_turfs.len = funky_turfs.len
		dancefloor_turfs_types.len = funky_turfs.len
		for(var/t in funky_turfs)
			var/turf/T = t
			dancefloor_turfs[i] = T
			dancefloor_turfs_types[i] = T.type
			T.ChangeTurf((i % 2 == 0) ? /turf/open/floor/light/colour_cycle/dancefloor_a : /turf/open/floor/light/colour_cycle/dancefloor_b, flags = CHANGETURF_INHERIT_AIR)
			i++

	return TRUE

/datum/effect_system/fluid_spread/smoke/transparent/dancefloor_devil
	effect_type = /obj/effect/particle_effect/fluid/smoke/transparent/dancefloor_devil

/obj/effect/particle_effect/fluid/smoke/transparent/dancefloor_devil
	lifetime = 2
