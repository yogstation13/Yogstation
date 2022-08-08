/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash
	name = "Ashen passage"
	desc = "Grants a short period of incorporeality, allowing passage through walls and other obstacles."
	school = "transmutation"
	charge_max = 150
	range = -1
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "ash_shift"
	action_background_icon_state = "bg_ecult"
	invocation = "ASH'N P'SSG'"
	jaunt_in_time = 13
	jaunt_duration = 10
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ash_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ash_shift/out

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/long
	jaunt_duration = 50

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/play_sound()
	return

/obj/effect/temp_visual/dir_setting/ash_shift
	name = "ash_shift"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ash_shift2"
	duration = 13

/obj/effect/temp_visual/dir_setting/ash_shift/out
	icon_state = "ash_shift"

/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp
	name = "Mansus Grasp"
	desc = "A powerful combat initiation spell that deals massive stamina damage. It may have other effects if you continue your research..."
	hand_path = /obj/item/melee/touch_attack/mansus_fist
	school = "evocation"
	charge_max = 150
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_grasp"
	action_background_icon_state = "bg_ecult"

/obj/item/melee/touch_attack/mansus_fist
	name = "Mansus Grasp"
	desc = "A sinister looking aura that distorts the flow of reality around it. Knocks the target down and deals a large amount of stamina damage alongside a small amount of brute. It may gain more interesting capabilities if you continue your research..."
	icon_state = "disintegrate"
	item_state = "disintegrate"
	color = '#00cc00'
	catchphrase = "R'CH T'H TR'TH"

/obj/item/melee/touch_attack/mansus_fist/ignition_effect(atom/A, mob/user)
	. = span_notice("[user] effortlessly snaps [user.p_their()] fingers near [A], igniting it with eldritch energies. Fucking badass!")
	qdel(src)

/obj/item/melee/touch_attack/mansus_fist/afterattack(atom/target, mob/user, proximity_flag, click_parameters)

	if(!proximity_flag || target == user)
		return
	if(ishuman(target))
		var/mob/living/carbon/human/tar = target
		if(tar.anti_magic_check())
			tar.visible_message(span_danger("Strange energies from [user]'s hand fly at [target] at an impossible velocity, but vanish before making contact!"),span_danger("Strange energies from [user]'s hand begin to crash at an impossible speed towards you, but vanish before they make contact!"))
			return ..()
	var/datum/mind/M = user.mind
	var/datum/antagonist/heretic/cultie = M.has_antag_datum(/datum/antagonist/heretic)

	var/use_charge = FALSE
	if(iscarbon(target))
		use_charge = TRUE
		var/mob/living/carbon/C = target
		C.adjustBruteLoss(10)
		C.AdjustKnockdown(5 SECONDS)
		C.adjustStaminaLoss(80)
		C.silent += 5
	var/list/knowledge = cultie.get_all_knowledge()

	for(var/X in knowledge)
		var/datum/eldritch_knowledge/EK = knowledge[X]
		if(EK.on_mansus_grasp(target, user, proximity_flag, click_parameters))
			use_charge = TRUE
	if(use_charge)
		playsound(user, 'sound/items/welder.ogg', 75, TRUE)
		return ..()

/obj/effect/proc_holder/spell/aoe_turf/rust_conversion
	name = "Aggressive Spread"
	desc = "Spread rust onto nearby turfs, possibly destroying rusted walls."
	school = "transmutation"
	charge_max = 300 //twice as long as mansus grasp
	clothes_req = FALSE
	invocation = "A'GRSV SPR'D"
	invocation_type = "whisper"
	range = 3
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "corrode"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/aoe_turf/rust_conversion/cast(list/targets, mob/user = usr)
	playsound(user, 'sound/items/welder.ogg', 75, TRUE)
	for(var/turf/T in targets)
		///What we want is the 3 tiles around the user and the tile under him to be rusted, so min(dist,1)-1 causes us to get 0 for these tiles, rest of the tiles are based on chance
		var/chance = 100 - (max(get_dist(T,user),1)-1)*100/(range+1)
		if(!prob(chance))
			continue
		T.rust_heretic_act()

/obj/effect/proc_holder/spell/aoe_turf/rust_conversion/small
	name = "Rust Conversion"
	desc = "Spreads rust onto nearby turfs."
	range = 2

/obj/effect/proc_holder/spell/targeted/touch/blood_siphon
	name = "Blood Siphon"
	desc = "Engulfs your arm in draining energies, absorbing the health of the first human-like being struck to heal yourself."
	hand_path = /obj/item/melee/touch_attack/blood_siphon
	school = "evocation"
	charge_max = 150
	clothes_req = FALSE
	invocation = "FL'MS O'ET'RN'ITY"
	invocation_type = "whisper"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "blood_siphon"
	action_background_icon_state = "bg_ecult"

/obj/item/melee/touch_attack/blood_siphon
	name = "Blood Siphon"
	desc = "A sinister looking aura that distorts the flow of reality around it. It looks <i>hungry</i>..."
	icon_state = "disintegrate"
	item_state = "disintegrate"
	catchphrase = "REGENERATE ME"

/obj/item/melee/touch_attack/blood_siphon/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	playsound(user, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	if(iscarbon(target))
		var/mob/living/carbon/C1 = target
		if(C1.anti_magic_check())
			C1.visible_message(span_danger("The energies from [user]'s hand jump at [target], but are dispersed!"),span_danger("Something jumps off of [user]'s hand, but it disperses on contact with you!"))
			return ..()
		var/mob/living/carbon/C2 = user
		for(var/obj/item/bodypart/bodypart in C2.bodyparts)
			for(var/i in bodypart.wounds)
				var/datum/wound/iter_wound = i
				if(prob(50))
					continue
				var/obj/item/bodypart/target_bodypart = locate(bodypart.type) in C1.bodyparts
				if(!target_bodypart)
					continue
				iter_wound.remove_wound()
				iter_wound.apply_wound(target_bodypart)
		if(isliving(target))
			var/mob/living/L = target
			L.adjustBruteLoss(20)
			C2.adjustBruteLoss(-20)
		C1.blood_volume -= 20
		if(C2.blood_volume < BLOOD_VOLUME_MAXIMUM(C2)) //we dont want to explode after all
			C2.blood_volume += 20
		return ..()

/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/rust_wave
	name = "Patron's Reach"
	desc = "Fire a rust spreading projectile in front of you, dealing toxin damage to whatever it hits."
	proj_type = /obj/item/projectile/magic/spell/rust_wave
	charge_max = 350
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "rust_wave"
	action_background_icon_state = "bg_ecult"
	invocation = "SPR'D TH' WO'D"
	invocation_type = "whisper"

/obj/item/projectile/magic/spell/rust_wave
	name = "Patron's Reach"
	icon_state = "eldritch_projectile"
	alpha = 180
	damage = 30
	damage_type = TOX
	nodamage = FALSE
	hitsound = 'sound/weapons/punch3.ogg'
	ignored_factions = list("heretics")
	range = 15
	speed = 1

/obj/item/projectile/magic/spell/rust_wave/Moved(atom/OldLoc, Dir)
	. = ..()
	playsound(src, 'sound/items/welder.ogg', 75, TRUE)
	var/list/turflist = list()
	var/turf/T1
	turflist += get_turf(src)
	T1 = get_step(src,turn(dir,90))
	turflist += T1
	turflist += get_step(T1,turn(dir,90))
	T1 = get_step(src,turn(dir,-90))
	turflist += T1
	turflist += get_step(T1,turn(dir,-90))
	for(var/X in turflist)
		if(!X || prob(25))
			continue
		var/turf/T = X
		T.rust_heretic_act()

/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/rust_wave/short
	name = "Small Patron's Reach"
	proj_type = /obj/item/projectile/magic/spell/rust_wave/short

/obj/item/projectile/magic/spell/rust_wave/short
	range = 7
	speed = 2

/obj/effect/proc_holder/spell/pointed/cleave
	name = "Cleave"
	desc = "Causes severe bleeding on a target and people around them"
	school = "transmutation"
	charge_max = 350
	clothes_req = FALSE
	invocation = "CL'VE"
	invocation_type = "whisper"
	range = 9
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "cleave"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/cleave/cast(list/targets, mob/user)
	if(!targets.len)
		to_chat(user, span_warning("No target found in range!"))
		return FALSE
	if(!can_target(targets[1], user))
		return FALSE

	for(var/mob/living/carbon/human/C in range(1,targets[1]))
		targets |= C


	for(var/X in targets)
		var/mob/living/carbon/human/target = X
		if(target == user)
			continue
		if(target.anti_magic_check())
			to_chat(user, span_warning("The spell had no effect!"))
			target.visible_message(span_danger("[target]'s veins emit a dull glow, but their magic protection repulses the blaze!"), \
							span_danger("You see a dull glow and feel a faint prickling sensation in your veins, but your magic protection prevents ignition!"))
			continue

		target.visible_message(span_danger("[target]'s veins are shredded from within as an unholy blaze erupts from their blood!"), \
							span_danger("You feel your skin scald as superheated blood bursts from your veins!"))
		var/obj/item/bodypart/bodypart = pick(target.bodyparts)
		var/datum/wound/slash/critical/crit_wound = new
		crit_wound.apply_wound(bodypart)
		target.adjustFireLoss(20)
		new /obj/effect/temp_visual/cleave(target.drop_location())

/obj/effect/proc_holder/spell/pointed/cleave/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target,/mob/living/carbon/human))
		if(!silent)
			to_chat(user, span_warning("You are unable to cleave [target]!"))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/cleave/long
	charge_max = 650

/obj/effect/proc_holder/spell/pointed/touch/mad_touch
	name = "Touch of madness"
	desc = "Strange energies engulf your hand, you feel even the sight of them would cause a headache if you didn't understand them."
	school = "transmutation"
	charge_max = 150
	clothes_req = FALSE
	invocation_type = "none"
	range = 2
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mad_touch"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/touch/mad_touch/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target,/mob/living/carbon/human))
		if(!silent)
			to_chat(user, span_warning("You are unable to touch [target]!"))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/touch/mad_touch/cast(list/targets, mob/user)
	. = ..()
	for(var/mob/living/carbon/target in targets)
		if(ishuman(targets))
			var/mob/living/carbon/human/tar = target
			if(tar.anti_magic_check())
				tar.visible_message(span_danger("The energies from [user]'s hand slide onto [target], but quickly fall off and vanish!"),span_danger("Something slides onto you from [user]'s hand, but it can't maintain contact and vanishes as it falls away!"))
				return
		if(target.mind && !target.mind.has_antag_datum(/datum/antagonist/heretic))
			to_chat(user,span_warning("[target.name] has been cursed!"))
			SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)

/obj/effect/proc_holder/spell/pointed/ash_final
	name = "Nightwatcher's Rite"
	desc = "Fires 5 blasts of fire in angles away from you, dealing heavy damage to anything they hit."
	school = "transmutation"
	invocation = "F'RE"
	invocation_type = "whisper"
	charge_max = 300
	range = 15
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "flames"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/ash_final/cast(list/targets, mob/user)
	for(var/X in targets)
		var/T
		T = line_target(-25, range, X, user)
		INVOKE_ASYNC(src, .proc/fire_line, user,T)
		T = line_target(10, range, X, user)
		INVOKE_ASYNC(src, .proc/fire_line, user,T)
		T = line_target(0, range, X, user)
		INVOKE_ASYNC(src, .proc/fire_line, user,T)
		T = line_target(-10, range, X, user)
		INVOKE_ASYNC(src, .proc/fire_line, user,T)
		T = line_target(25, range, X, user)
		INVOKE_ASYNC(src, .proc/fire_line, user,T)
	return ..()

/obj/effect/proc_holder/spell/pointed/ash_final/proc/line_target(offset, range, atom/at , atom/user)
	if(!at)
		return
	var/angle = ATAN2(at.x - user.x, at.y - user.y) + offset
	var/turf/T = get_turf(user)
	for(var/i in 1 to range)
		var/turf/check = locate(user.x + cos(angle) * i, user.y + sin(angle) * i, user.z)
		if(!check)
			break
		T = check
	return (getline(user, T) - get_turf(user))

/obj/effect/proc_holder/spell/pointed/ash_final/proc/fire_line(atom/source, list/turfs)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			break

		for(var/mob/living/L in T.contents)
			if(L.anti_magic_check())
				L.visible_message(span_danger("The fire parts in front of [L]!"),span_danger("As the fire approaches it splits off to avoid contact with you!"))
				continue
			if(L in hit_list || L == source)
				continue
			hit_list += L
			L.adjustFireLoss(20)
			to_chat(L, span_userdanger("You're hit by [source]'s fire breath!"))

		new /obj/effect/hotspot(T)
		T.hotspot_expose(700,50,1)
		// deals damage to mechs
		for(var/obj/mecha/M in T.contents)
			if(M in hit_list)
				continue
			hit_list += M
			M.take_damage(45, BURN, MELEE, 1)
		sleep(0.15 SECONDS)

/obj/effect/proc_holder/spell/targeted/shapeshift/eldritch
	invocation = "BEND MY FORM"
	invocation_type = "whisper"
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	possible_shapes = list(/mob/living/simple_animal/mouse,\
		/mob/living/simple_animal/pet/dog/corgi,\
		/mob/living/simple_animal/hostile/carp/megacarp,\
		/mob/living/simple_animal/pet/fox,\
		/mob/living/simple_animal/hostile/netherworld/migo,\
		/mob/living/simple_animal/bot/medbot,\
		/mob/living/simple_animal/pet/cat )

/obj/effect/proc_holder/spell/targeted/emplosion/eldritch
	name = "Entropic Pulse"
	invocation = "E'P"
	invocation_type = "whisper"
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 300
	emp_heavy = 6
	emp_light = 10

/obj/effect/proc_holder/spell/aoe_turf/fire_cascade
	name = "Fire Cascade"
	desc = "Creates a large cascading burst of flames around you."
	school = "transmutation"
	charge_max = 300 //twice as long as mansus grasp
	clothes_req = FALSE
	invocation = "C'SC'DE"
	invocation_type = "shout"
	range = 4
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "fire_ring"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/aoe_turf/fire_cascade/cast(list/targets, mob/user = usr)
	INVOKE_ASYNC(src, .proc/fire_cascade, user,range)

/obj/effect/proc_holder/spell/aoe_turf/fire_cascade/proc/fire_cascade(atom/centre,max_range)
	playsound(get_turf(centre), 'sound/items/welder.ogg', 75, TRUE)
	var/_range = 1
	for(var/i = 0, i <= max_range,i++)
		for(var/turf/T in spiral_range_turfs(_range,centre))
			new /obj/effect/hotspot(T)
			T.hotspot_expose(700,50,1)
			for(var/mob/living/livies in T.contents - centre)
				livies.adjustFireLoss(5)
		_range++
		sleep(0.3 SECONDS)

/obj/effect/proc_holder/spell/aoe_turf/fire_cascade/big
	range = 6

/obj/effect/proc_holder/spell/targeted/telepathy/eldritch
	invocation = ""
	invocation_type = "whisper"
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/targeted/fire_sworn
	name = "Oath of Fire"
	desc = "Engulf yourself in a cloak of flames for a minute. The flames are harmless to you, but dangerous to anyone else."
	invocation = "FL'MS"
	invocation_type = "shout"
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 700
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "fire_ring"
	///how long it lasts
	var/duration = 1 MINUTES
	///who casted it right now
	var/mob/current_user
	///Determines if you get the fire ring effect
	var/has_fire_ring = FALSE

/obj/effect/proc_holder/spell/targeted/fire_sworn/cast(list/targets, mob/user)
	. = ..()
	current_user = user
	has_fire_ring = TRUE
	addtimer(CALLBACK(src, .proc/remove, user), duration, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/effect/proc_holder/spell/targeted/fire_sworn/proc/remove()
	has_fire_ring = FALSE

/obj/effect/proc_holder/spell/targeted/fire_sworn/process()
	. = ..()
	if(!has_fire_ring)
		return
	for(var/turf/T in range(1,current_user))
		new /obj/effect/hotspot(T)
		T.hotspot_expose(700,50,1)
		for(var/mob/living/L in T.contents - current_user)
			L.adjustFireLoss(2.5)


/obj/effect/proc_holder/spell/targeted/worm_contract
	name = "Force Contract"
	desc = "Forces all the worm parts to collapse onto a single turf"
	invocation_type = "none"
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 300
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "worm_contract"

/obj/effect/proc_holder/spell/targeted/worm_contract/cast(list/targets, mob/user)
	. = ..()
	if(!istype(user,/mob/living/simple_animal/hostile/eldritch/armsy))
		to_chat(user, span_userdanger("You try to contract your muscles but nothing happens..."))
		return
	var/mob/living/simple_animal/hostile/eldritch/armsy/armsy = user
	armsy.contract_next_chain_into_single_tile()

/obj/effect/temp_visual/cleave
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cleave"
	duration = 6

/obj/effect/temp_visual/eldritch_smoke
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "smoke"
	duration = 10

/obj/effect/proc_holder/spell/targeted/fiery_rebirth
	name = "Nightwatcher's Rebirth"
	desc = "Drains the health of nearby combusting individuals, healing you 10 of each damage type for every victim. If a victim is in critical condition they will be finished off."
	invocation = "GL'RY T' TH' N'GHT'W'TCH'ER"
	invocation_type = "whisper"
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 600
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "smoke"

/obj/effect/proc_holder/spell/targeted/fiery_rebirth/cast(list/targets, mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	for(var/mob/living/carbon/target in view(7,user))
		if(target.stat == DEAD || !target.on_fire)
			continue
		//This is essentially a death mark, use this to finish your opponent quicker.
		if(target.InCritical())
			target.death()
		target.adjustFireLoss(20)
		new /obj/effect/temp_visual/eldritch_smoke(target.drop_location())
		human_user.ExtinguishMob()
		human_user.adjustBruteLoss(-10, FALSE)
		human_user.adjustFireLoss(-10, FALSE)
		human_user.adjustStaminaLoss(-10, FALSE)
		human_user.adjustToxLoss(-10, FALSE)
		human_user.adjustOxyLoss(-10)

/obj/effect/proc_holder/spell/pointed/manse_link
	name = "Mansus Link"
	desc = "Pierce through reality, connecting minds. Hitting someone with this spell will add them to your mansus link shortly after if uninterrupted, allowing for silent communication."
	school = "transmutation"
	charge_max = 300
	clothes_req = FALSE
	invocation = "PI'RC' TH' M'ND"
	invocation_type = "whisper"
	range = 10
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_link"
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/manse_link/can_target(atom/target, mob/user, silent)
	if(!isliving(target))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/manse_link/cast(list/targets, mob/user)
	var/mob/living/simple_animal/hostile/eldritch/raw_prophet/originator = user

	var/mob/living/target = targets[1]

	to_chat(originator, span_notice("You begin linking [target]'s mind to yours..."))
	to_chat(target, span_warning("You feel your mind being pulled... connected... to something unreal..."))
	if(!do_after(originator, 6 SECONDS, target))
		return
	if(!originator.link_mob(target))
		to_chat(originator, span_warning("You can't seem to link [target]'s mind..."))
		to_chat(target, span_warning("The foreign presence leaves your mind."))
		return
	to_chat(originator, span_notice("You connect [target]'s mind to your mansus link!"))


/datum/action/innate/mansus_speech
	name = "Mansus Link"
	desc = "Send a psychic message to everyone connected to your mansus link."
	button_icon_state = "link_speech"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_ecult"
	var/mob/living/simple_animal/hostile/eldritch/raw_prophet/originator

/datum/action/innate/mansus_speech/New(_originator)
	. = ..()
	originator = _originator

/datum/action/innate/mansus_speech/Activate()
	var/mob/living/living_owner = owner
	if(!originator?.linked_mobs[living_owner])
		CRASH("Uh oh the mansus link got somehow activated without it being linked to a raw prophet or the mob not being in a list of mobs that should be able to do it.")

	var/message = sanitize(input("Message:", "Telepathy from the Manse") as text|null)

	if(QDELETED(living_owner))
		return

	if(!originator?.linked_mobs[living_owner])
		to_chat(living_owner, span_warning("The link seems to have been severed..."))
		Remove(living_owner)
		return
	if(message)
		var/msg = "<i><font color=#568b00>\[Mansus Link\] <b>[living_owner]:</b> [message]</font></i>"
		log_directed_talk(living_owner, originator, msg, LOG_SAY, "Mansus Link")
		to_chat(originator.linked_mobs, msg)

		for(var/dead_mob in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(dead_mob, living_owner)
			to_chat(dead_mob, "[link] [msg]")

/obj/effect/proc_holder/spell/pointed/trigger/blind/eldritch
	range = 10
	invocation = "E'E'S"
	action_background_icon_state = "bg_ecult"

/obj/effect/temp_visual/dir_setting/entropic
	icon = 'icons/effects/160x160.dmi'
	icon_state = "entropic_plume"
	duration = 3 SECONDS

/obj/effect/temp_visual/dir_setting/entropic/setDir(dir)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_x = -64
		if(SOUTH)
			pixel_x = -64
			pixel_y = -128
		if(EAST)
			pixel_y = -64
		if(WEST)
			pixel_y = -64
			pixel_x = -128

/obj/effect/glowing_rune
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "small_rune_1"
	layer = LOW_SIGIL_LAYER

/obj/effect/glowing_rune/Initialize()
	. = ..()
	pixel_y = rand(-6,6)
	pixel_x = rand(-6,6)
	icon_state = "small_rune_[rand(12)]"
	update_icon()

/obj/effect/proc_holder/spell/cone/staggered/entropic_plume
	name = "Entropic Plume"
	desc = "Spews forth a disorienting plume that causes enemies to strike each other, briefly blinds them(increasing with range) and poisons them(decreasing with range), while also spreading rust in the path of the plume."
	school = "illusion"
	invocation = "'NTR'P'C PL'M'"
	invocation_type = "whisper"
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "entropic_plume"
	charge_max = 300
	cone_levels = 5
	respect_density = TRUE

/obj/effect/proc_holder/spell/cone/staggered/entropic_plume/cast(list/targets,mob/user = usr)
	. = ..()
	new /obj/effect/temp_visual/dir_setting/entropic(get_step(user,user.dir), user.dir)

/obj/effect/proc_holder/spell/cone/staggered/entropic_plume/do_turf_cone_effect(turf/target_turf, level)
	. = ..()
	target_turf.rust_heretic_act()

/obj/effect/proc_holder/spell/cone/staggered/entropic_plume/do_mob_cone_effect(mob/living/victim, level)
	. = ..()
	if(victim.anti_magic_check() || IS_HERETIC(victim) || IS_HERETIC_MONSTER(victim))
		return
	victim.apply_status_effect(STATUS_EFFECT_AMOK)
	victim.apply_status_effect(STATUS_EFFECT_CLOUDSTRUCK, (level*10))
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		carbon_victim.reagents.add_reagent(/datum/reagent/eldritch, min(1, 6-level))

/obj/effect/proc_holder/spell/cone/staggered/entropic_plume/calculate_cone_shape(current_level)
	if(current_level == cone_levels)
		return 5
	else if(current_level == cone_levels-1)
		return 3
	else
		return 2
