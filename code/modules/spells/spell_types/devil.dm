/obj/effect/proc_holder/spell/targeted/conjure_item/summon_pitchfork
	name = "Summon Pitchfork"
	desc = "A devil's weapon of choice.  Use this to summon/unsummon your pitchfork."
	invocation_type = "none"
	include_user = TRUE
	range = -1
	clothes_req = FALSE
	item_type = /obj/item/twohanded/pitchfork/demonic

	school = "conjuration"
	charge_max = 150
	cooldown_min = 10
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "pitchfork"
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/targeted/conjure_item/summon_pitchfork/greater
	item_type = /obj/item/twohanded/pitchfork/demonic/greater

/obj/effect/proc_holder/spell/targeted/conjure_item/summon_pitchfork/ascended
	item_type = /obj/item/twohanded/pitchfork/demonic/ascended

/obj/effect/proc_holder/spell/targeted/conjure_item/violin
	item_type = /obj/item/instrument/violin/golden
	desc = "A devil's instrument of choice.  Use this to summon/unsummon your golden violin."
	invocation_type = "whisper"
	invocation = "I aint have this much fun since Georgia."
	action_icon_state = "golden_violin"
	name = "Summon golden violin"
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/targeted/summon_contract
	name = "Summon infernal contract"
	desc = "Skip making a contract by hand, just do it by magic."
	invocation_type = "whisper"
	invocation = "Just sign on the dotted line."
	include_user = FALSE
	range = 5
	clothes_req = FALSE

	school = "conjuration"
	charge_max = 150
	cooldown_min = 10
	action_icon_state = "spell_default"
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/targeted/summon_contract/cast(list/targets, mob/user = usr)
	var/datum/antagonist/devil/D = user.mind.has_antag_datum(/datum/antagonist/devil)
	for(var/mob/living/carbon/human/C in targets)
		if(D.obsession == "species" && C.dna.species.name != "[D.actual_obsession]")
			return to_chat(user, "<span class='notice'>This soul does not suit our tastes.")
		if(D.obsession == "gender" && C.gender != "[D.actual_obsession]")
			return to_chat(user, "<span class='notice'>This soul does not suit our tastes.")
		if(D.obsession == "blood" && C.dna.blood_type != "[D.actual_obsession]")
			return to_chat(user, "<span class='notice'>This soul does not suit our tastes.")
		if(D.obsession == "age")
			if(D.actual_obsession == "16 to 30" && C.age >29)
				return to_chat(user, "<span class='notice'>This soul does not suit our tastes.")
			if(D.actual_obsession == "30 and up" && C.age <30)
				return to_chat(user, "<span class='notice'>This soul does not suit our tastes.")
		if(C.sold_soul)
			return to_chat(user, "<span class='notice'>[C] has already sold their soul to something far more evil than us.</span>")

		if(C.mind && user.mind)
			if(C.stat == DEAD)
				if(user.dropItemToGround(user.get_active_held_item()))
					var/obj/item/paper/contract/infernal/revive/contract = new(user.loc, C.mind, user.mind)
					user.put_in_hands(contract)
			else
				var/obj/item/paper/contract/infernal/contract  // = new(user.loc, C.mind, contractType, user.mind)
				var/contractTypeName = input(user, "What type of contract?") in list ("Power", "Life", "Wealth", "Prestige", "Magic", "Knowledge", "Science", "Friendship")
				switch(contractTypeName)
					if("Power")
						contract = new /obj/item/paper/contract/infernal/power(C.loc, C.mind, user.mind)
					if("Life")
						contract = new /obj/item/paper/contract/infernal/life(C.loc, C.mind, user.mind)
					if("Wealth")
						contract = new /obj/item/paper/contract/infernal/wealth(C.loc, C.mind, user.mind)
					if("Prestige")
						contract = new /obj/item/paper/contract/infernal/prestige(C.loc, C.mind, user.mind)
					if("Magic")
						contract = new /obj/item/paper/contract/infernal/magic(C.loc, C.mind, user.mind)
					if("Knowledge")
						contract = new /obj/item/paper/contract/infernal/knowledge(C.loc, C.mind, user.mind)
					if("Science")
						contract = new /obj/item/paper/contract/infernal/science(C.loc, C.mind, user.mind)
					if("Friendship")
						contract = new /obj/item/paper/contract/infernal/friend(C.loc, C.mind, user.mind)
				C.put_in_hands(contract)
		else
			to_chat(user, "<span class='notice'>[C] seems to not be sentient.  You cannot summon a contract for [C.p_them()].</span>")


/obj/effect/proc_holder/spell/aimed/fireball/hellish
	name = "Hellfire"
	desc = "This spell launches hellfire at the target."

	school = "evocation"
	charge_max = 80
	clothes_req = FALSE
	invocation = "Your very soul will catch fire!"
	invocation_type = "shout"
	range = 2

	projectile_type = /obj/item/projectile/magic/aoe/fireball/infernal

	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/targeted/infernal_jaunt
	name = "Infernal Jaunt"
	desc = "Use hellfire to phase out of existence."
	charge_max = 200
	clothes_req = FALSE
	selection_type = "range"
	range = -1
	cooldown_min = 0
	overlay = null
	include_user = TRUE
	action_icon_state = "jaunt"
	action_background_icon_state = "bg_demon"
	phase_allowed = TRUE

/obj/effect/proc_holder/spell/targeted/infernal_jaunt/cast(list/targets, mob/living/user = usr)
	if(istype(user))
		if(istype(user.loc, /obj/effect/dummy/phased_mob/slaughter/))
			if(valid_location(user))
				to_chat(user, "<span class='warning'>You are now phasing in. Move away from a living creature to cancel this.</span>")
				if(!do_mob(user,user,50, 0, 1))
					return
				to_chat(user, "<span class='warning'>You begin to reshape your mortal form.</span>")
				if(!do_mob(user,user,50, 0, 1))
					return
				to_chat(user, "<span class='warning'>You re-enter the mortal plane.</span>")
				if(valid_location(user))
					user.infernalphasein()
				if(!valid_location(user))
					to_chat(user, "<span class='warning'>You are no longer near a potential signer. This will take us a little longer.</span>")
					if(do_mob(user,user,50, 0, 1))
						user.infernalphasein()

			else
				to_chat(user, "<span class='warning'>You can only re-appear near a potential signer.</span>")
				revert_cast()
				return ..()
		else
			user.notransform = TRUE
			user.fakefire()
			to_chat(user, "<span class='warning'>You must hold still for this.</span>")
			if(do_mob(user,user,50, 0, 1))
				to_chat(user, "<span class='warning'>You begin to phase back into sinful flames.</span>")
			if(do_mob(user,user,50, 0, 1))
				user.infernalphaseout()
			else
				to_chat(user, "<span class='warning'>You must remain still while exiting.</span>")
				user.notransform = FALSE
				user.fakefireextinguish()
		start_recharge()
		return
	revert_cast()

/obj/effect/proc_holder/spell/targeted/infernal_jaunt/proc/valid_location(mob/living/user = usr)
	if(istype(get_area(user), /area/shuttle/)) // Can always phase in in a shuttle.
		return TRUE
	else
		for(var/mob/living/C in orange(6, get_turf(user))) //Can also phase in when nearby a potential buyer.
			if (C.owns_soul())
				return TRUE
	return FALSE

/mob/living/proc/infernalphaseout()
	dust_animation()
	spawn_dust()
	visible_message("<span class='warning'>[src] disappears in a flashfire!</span>")
	playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 100, 1, -1)
	var/obj/effect/dummy/phased_mob/slaughter/holder = new /obj/effect/dummy/phased_mob/slaughter(loc)
	ExtinguishMob()
	forceMove(holder)
	holder = holder
	notransform = FALSE
	fakefireextinguish()

/mob/living/proc/infernalphasein()
	if(notransform)
		to_chat(src, "<span class='warning'>You're too busy to jaunt in.</span>")
		return FALSE
	fakefire()
	forceMove(drop_location())
	client.eye = src
	visible_message("<span class='warning'><B>[src] appears in a fiery blaze!</B></span>")
	playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 100, 1, -1)
	addtimer(CALLBACK(src, .proc/fakefireextinguish), 15, TIMER_UNIQUE)

/obj/effect/proc_holder/spell/targeted/sintouch
	name = "Sin Touch"
	desc = "Subtly encourage someone to sin."
	charge_max = 1800
	clothes_req = FALSE
	selection_type = "range"
	range = 2
	cooldown_min = 0
	overlay = null
	include_user = FALSE
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "sintouch"
	action_background_icon_state = "bg_demon"
	phase_allowed = FALSE
	random_target = TRUE
	random_target_priority = TARGET_RANDOM
	max_targets = 3
	invocation = "TASTE SIN AND INDULGE!!"
	invocation_type = "shout"

/obj/effect/proc_holder/spell/targeted/sintouch/ascended
	name = "Greater sin touch"
	charge_max = 100
	range = 7
	max_targets = 10

/obj/effect/proc_holder/spell/targeted/sintouch/cast(list/targets, mob/living/user = usr)
	for(var/mob/living/carbon/human/H in targets)
		if(!H.mind)
			continue
		if(H.mind.has_antag_datum(/datum/antagonist/sintouched))
			continue
		if(H.anti_magic_check(FALSE, TRUE))
			continue
		H.mind.add_antag_datum(/datum/antagonist/sintouched)
		H.Paralyze(400)


/obj/effect/proc_holder/spell/targeted/summon_dancefloor
	name = "Summon Dancefloor"
	desc = "When what a Devil really needs is funk."
	include_user = TRUE
	range = -1
	clothes_req = FALSE

	school = "conjuration"
	charge_max = 10
	cooldown_min = 50 //5 seconds, so the smoke can't be spammed
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "funk"
	action_background_icon_state = "bg_demon"

	var/list/dancefloor_turfs
	var/list/dancefloor_turfs_types
	var/dancefloor_exists = FALSE
	var/datum/effect_system/smoke_spread/transparent/dancefloor_devil/smoke


/obj/effect/proc_holder/spell/targeted/summon_dancefloor/cast(list/targets, mob/user = usr)
	LAZYINITLIST(dancefloor_turfs)
	LAZYINITLIST(dancefloor_turfs_types)

	if(!smoke)
		smoke = new()
	smoke.set_up(0, get_turf(user))
	smoke.start()

	if(dancefloor_exists)
		dancefloor_exists = FALSE
		for(var/i in 1 to dancefloor_turfs.len)
			var/turf/T = dancefloor_turfs[i]
			T.ChangeTurf(dancefloor_turfs_types[i], flags = CHANGETURF_INHERIT_AIR)
	else
		var/list/funky_turfs = RANGE_TURFS(1, user)
		for(var/turf/closed/solid in funky_turfs)
			to_chat(user, "<span class='warning'>You're too close to a wall.</span>")
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

/datum/effect_system/smoke_spread/transparent/dancefloor_devil
	effect_type = /obj/effect/particle_effect/smoke/transparent/dancefloor_devil

/obj/effect/particle_effect/smoke/transparent/dancefloor_devil
	lifetime = 2

/obj/effect/proc_holder/spell/targeted/devilshapeshift
	name = "Shapeshift"
	desc = "Changes your name and appearance with a cooldown of 3 minutes."
	action_icon_state = "genetic_poly"
	action_icon = 'yogstation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	clothes_req = FALSE
	include_user = TRUE
	range = -1
	charge_max = 1800 // 3 minutes.

/obj/effect/proc_holder/spell/targeted/devilshapeshift/cast(list/targets, mob/user = usr)
	user.visible_message("<span class='warning'>[user] transforms!</span>")
	randomize_human(user)
	user.regenerate_icons()

/obj/effect/proc_holder/spell/targeted/devilhelp
	name = "Devil Help"
	desc = "Explains how the Devil does business."
	action_icon_state ="demonomicon"
	action_icon = 'icons/obj/library.dmi'
	action_background_icon_state = "bg_demon"
	clothes_req = FALSE
	include_user = TRUE
	range = -1
	charge_max = 50

/obj/effect/proc_holder/spell/targeted/devilhelp/cast(list/targets, mob/user = usr)
	to_chat(user, "<span class='notice'>Your Summon infernal contract spell will create a contract in the hand of the targeted user. If your chosen target does not fufill your obsession, the contract will not appear for them, but they will still see you cast your magicks.</span>")
	to_chat(user, "<span class='warning'>Be warned, your contracts include your full name, and can be used against you to find your weakness. Make sure they are willing to sign before you give them a contract.</span>")
	to_chat(user, "<span class='notice'>Infernal Jaunt will allow you move through walls and stalk your targets, seeing and hearing what they can. Use this to discover what it is they want most.</span>")
	to_chat(user, "<span class='warning'>After collecting three souls, you will ascend into a higher form of life, the Blood Lizard. This will make your presence more noticeable, and may frighten mortals. It may not be wise to ascend this far if you are not required to.</span>")