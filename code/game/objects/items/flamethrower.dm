/obj/item/flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'yogstation/icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamethrower_0"
	lefthand_file = 'icons/mob/inhands/weapons/flamethrower_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/flamethrower_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 3
	throwforce = 10
	var/acti_sound = 'sound/items/welderactivate.ogg'
	var/deac_sound = 'sound/items/welderdeactivate.ogg'
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(/datum/material/iron=500)
	resistance_flags = FIRE_PROOF
	light_system = MOVABLE_LIGHT
	light_on = FALSE
	var/status = FALSE
	var/lit = FALSE	//on or off
	light_range = 2
	light_color = LIGHT_COLOR_FIRE
	var/operating = FALSE//cooldown
	var/obj/item/weldingtool/weldtool = null
	var/obj/item/assembly/igniter/igniter = null
	var/obj/item/tank/internals/plasma/ptank = null
	var/warned_admins = FALSE //for the message_admins() when lit
	//variables for prebuilt flamethrowers
	var/create_full = FALSE
	var/create_with_tank = FALSE
	var/igniter_type = /obj/item/assembly/igniter
	var/max_damage = 16 // maximum direct burn damage it can cause
	var/list/flame_sounds = list('sound/weapons/flamethrower1.ogg','sound/weapons/flamethrower2.ogg','sound/weapons/flamethrower3.ogg')
	trigger_guard = TRIGGER_GUARD_NORMAL

/obj/item/flamethrower/Destroy()
	if(weldtool)
		qdel(weldtool)
	if(igniter)
		qdel(igniter)
	if(ptank)
		qdel(ptank)
	return ..()

/obj/item/flamethrower/process()
	if(!lit || !igniter)
		STOP_PROCESSING(SSobj, src)
		return null
	var/turf/location = loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.is_holding(src))
			location = M.loc
	if(isturf(location)) //start a fire if possible
		igniter.flamethrower_process(location)


/obj/item/flamethrower/update_overlays()
	. = ..()
	if(igniter)
		. += "+igniter[status]"
	if(ptank)
		. += "+ptank"
	if(lit)
		. += "+lit"
		item_state = "flamethrower_1"
	else
		item_state = "flamethrower_0"
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()
	return

/obj/item/flamethrower/afterattack(atom/target, mob/user, flag)
	. = ..()
	if(flag)
		return // too close
	if(ishuman(user))
		if(!can_trigger_gun(user))
			return
	if(world.time < user.next_move)
		return // no spam allowed
	if(user && user.get_active_held_item() == src) // Make sure our user is still holding us
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = getline(user, target_turf)
			log_combat(user, target, "flamethrowered", src)
			user.changeNext_move(CLICK_CD_RANGE)
			flame_turf(turflist)

/obj/item/flamethrower/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH && !status)//Taking this apart
		var/turf/T = get_turf(src)
		if(weldtool)
			weldtool.forceMove(T)
			weldtool = null
		if(igniter)
			igniter.forceMove(T)
			igniter = null
		if(ptank)
			ptank.forceMove(T)
			ptank = null
		new /obj/item/stack/rods(T)
		qdel(src)
		return

	else if(W.tool_behaviour == TOOL_SCREWDRIVER && igniter && !lit)
		status = !status
		to_chat(user, span_notice("[igniter] is now [status ? "secured" : "unsecured"]!"))
		update_appearance(UPDATE_ICON)
		return

	else if(isigniter(W))
		var/obj/item/assembly/igniter/I = W
		if(I.secured)
			return
		if(igniter)
			return
		if(!user.transferItemToLoc(W, src))
			return
		igniter = I
		update_appearance(UPDATE_ICON)
		return

	else if(istype(W, /obj/item/tank/internals/plasma))
		if(ptank)
			if(user.transferItemToLoc(W,src))
				user.put_in_active_hand(W) // FLAMETHROWER TACTICAL RELOAD
				ptank = W
				to_chat(user, span_notice("You swap the plasma tank in [src]!"))
			return
		if(!user.transferItemToLoc(W, src))
			return
		ptank = W
		update_appearance(UPDATE_ICON)
		return

	else
		return ..()

/obj/item/flamethrower/return_analyzable_air()
	if(ptank)
		return ptank.return_analyzable_air()
	else
		return null


/obj/item/flamethrower/attack_self(mob/user)
	toggle_igniter(user)

/obj/item/flamethrower/AltClick(mob/user)
	if(ptank && isliving(user) && user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		user.put_in_hands(ptank)
		ptank = null
		to_chat(user, span_notice("You remove the plasma tank from [src]!"))
		update_appearance(UPDATE_ICON)

/obj/item/flamethrower/examine(mob/user)
	. = ..()
	if(ptank)
		. += span_notice("\The [src] has \a [ptank] attached. Alt-click to remove it.")

/obj/item/flamethrower/proc/toggle_igniter(mob/user)
	if(!ptank)
		to_chat(user, span_notice("Attach a plasma tank first!"))
		return
	if(!status)
		to_chat(user, span_notice("Secure the igniter first!"))
		return
	to_chat(user, span_notice("You [lit ? "extinguish" : "ignite"] [src]!"))
	lit = !lit
	if(lit)
		playsound(loc, acti_sound, 50, TRUE)
		START_PROCESSING(SSobj, src)
		if(!warned_admins)
			message_admins("[ADMIN_LOOKUPFLW(user)] has lit a flamethrower.")
			warned_admins = TRUE
	else
		playsound(loc, deac_sound, 50, TRUE)
		STOP_PROCESSING(SSobj,src)
	set_light_on(lit)
	update_appearance(UPDATE_ICON)

/obj/item/flamethrower/CheckParts(list/parts_list)
	..()
	weldtool = locate(/obj/item/weldingtool) in contents
	igniter = locate(/obj/item/assembly/igniter) in contents
	weldtool.status = FALSE
	igniter.secured = FALSE
	status = TRUE
	update_appearance(UPDATE_ICON)

/obj/item/flamethrower/proc/process_fuel(turf/open/target, release_all = FALSE)
	if(!(ptank.air_contents && ptank.air_contents.return_pressure()))
		return kill_flame()
	
	if(!istype(target))
		return FALSE

	var/ratio_removed = 1
	if(!release_all)
		ratio_removed = min(ptank.distribute_pressure, ptank.air_contents.return_pressure()) / ptank.air_contents.return_pressure()
	var/datum/gas_mixture/fuel_mix = ptank.air_contents.remove_ratio(ratio_removed)

	// Return of the stimball flamethrower, wear radiation protection when using this or you're just as likely to die as your target
	if(fuel_mix.get_moles(/datum/gas/plasma) >= NITRO_BALL_MOLES_REQUIRED && fuel_mix.get_moles(/datum/gas/nitrium) >= NITRO_BALL_MOLES_REQUIRED && fuel_mix.get_moles(/datum/gas/pluoxium) >= NITRO_BALL_MOLES_REQUIRED)
		var/balls_shot = round(min(fuel_mix.get_moles(/datum/gas/nitrium), fuel_mix.get_moles(/datum/gas/pluoxium), NITRO_BALL_MAX_REACT_RATE / NITRO_BALL_MOLES_REQUIRED))
		var/angular_increment = 360/balls_shot
		var/random_starting_angle = rand(0,360)
		for(var/i in 1 to balls_shot)
			target.fire_nuclear_particle((i*angular_increment+random_starting_angle))
		fuel_mix.adjust_moles(/datum/gas/plasma, -balls_shot * NITRO_BALL_MOLES_REQUIRED) // No free extra damage for you, conservation of mass go brrrrr

	// Funny rad flamethrower go brrr
	if(fuel_mix.get_moles(/datum/gas/tritium)) // Tritium fires cause a bit of radiation
		radiation_pulse(target, min(fuel_mix.get_moles(/datum/gas/tritium), fuel_mix.get_moles(/datum/gas/oxygen)/2) * FIRE_HYDROGEN_ENERGY_RELEASED / TRITIUM_BURN_RADIOACTIVITY_FACTOR)

	// 8 damage at 0.5 mole transfer or ~17 kPa release pressure
	// 16 damage at 1 mole transfer or ~35 kPa release pressure
	var/damage = fuel_mix.get_moles(/datum/gas/plasma) * 16
	// harder to achieve than plasma
	damage += fuel_mix.get_moles(/datum/gas/tritium) * 24 // Lower damage than hydrogen, causes minor radiation
	damage += fuel_mix.get_moles(/datum/gas/hydrogen) * 32
	// Maximum damage restricted by the available oxygen, with a hard cap at 16
	var/datum/gas_mixture/turf_air = target.return_air()
	damage = min(damage, turf_air.get_moles(/datum/gas/oxygen) + fuel_mix.get_moles(/datum/gas/oxygen), max_damage) // capped by combined oxygen in the fuel mix and enviroment

	// If there's not enough fuel and/or oxygen to do more than 1 damage, shut itself off
	if(damage < 1)
		return kill_flame()
	return damage

/obj/item/flamethrower/proc/kill_flame()
	visible_message(span_danger("\The [src] breathes a sighed hiss as its flame dies out."))
	lit = FALSE
	set_light_on(FALSE)
	playsound(loc, 'sound/weapons/flamethrower_empty.ogg', 50, TRUE)
	STOP_PROCESSING(SSobj,src)
	update_appearance(UPDATE_ICON)
	return FALSE

//Called from turf.dm turf/dblclick
/obj/item/flamethrower/proc/flame_turf(turflist)
	if(!lit || operating)
		return FALSE
	operating = TRUE
	var/sound_played = FALSE // don't spam the sound
	var/turf/previousturf = get_turf(src)
	for(var/turf/T in turflist)
		if(T == previousturf)
			continue	//so we don't burn the tile we be standin on
		for(var/obj/structure/blob/B in T)
			// This is run before atmos checks because blob can be atmos blocking but we still want to hit them
			// See /proc/default_ignite
			var/damage = process_fuel(T)
			if(!damage)
				break // Out of gas, stop running pointlessly
			B.take_damage(damage * 2, BURN, FIRE) // strong against blobs
		var/list/turfs_sharing_with_prev = previousturf.GetAtmosAdjacentTurfs(alldir=1)
		if(!(T in turfs_sharing_with_prev))
			break // Hit something that blocks atmos
		if(igniter)
			if(!igniter.ignite_turf(src,T))
				break // Out of gas, stop running pointlessly
		else
			if(!default_ignite(T))
				break // Out of gas, stop running pointlessly
		if(!sound_played) // play the sound once if we successfully ignite at least one thing
			sound_played = TRUE
			playsound(loc, pick(flame_sounds), 50, TRUE)
		sleep(0.1 SECONDS)
		previousturf = T
	operating = FALSE
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)


	// /obj/structure/blob/normal

// Return value tells the parent whether to continue calculating the line
/obj/item/flamethrower/proc/default_ignite(turf/target, release_all = FALSE)
	// do the fuel stuff
	var/damage = process_fuel(target, release_all)
	if(!damage)
		return FALSE

	//Burn it
	var/list/hit_list = list()
	hit_list += src
	target.IgniteTurf(rand(damage, damage * 4))

	// Fire go brrrr
	for(var/mob/living/L in target.contents)
		if(L in hit_list)
			continue
		hit_list += L
		var/hit_percent = (100 - L.getarmor(null, FIRE)) / 100
		L.apply_damage_type(damage * hit_percent, BURN)
		to_chat(L, "<span class='userdanger'>A waft of flames overtakes you!</span>")
	// deals damage to mechs
	for(var/obj/mecha/M in target.contents)
		if(M in hit_list)
			continue
		hit_list += M
		M.take_damage(damage, BURN, FIRE, 1)
	
	return TRUE

/obj/item/flamethrower/Initialize(mapload)
	. = ..()
	if(create_full)
		if(!weldtool)
			weldtool = new /obj/item/weldingtool(src)
		weldtool.status = FALSE
		if(!igniter)
			igniter = new igniter_type(src)
		igniter.secured = FALSE
		status = TRUE
		if(create_with_tank)
			ptank = new /obj/item/tank/internals/plasma/full(src)
		update_appearance(UPDATE_ICON)

/obj/item/flamethrower/full
	create_full = TRUE

/obj/item/flamethrower/full/tank
	create_with_tank = TRUE

/obj/item/flamethrower/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/obj/item/projectile/P = hitby
	if(damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(5))
		owner.visible_message(span_danger("\The [attack_text] hits the fueltank on [owner]'s [name], rupturing it! What a shot!"))
		var/target_turf = get_turf(owner)
		igniter.ignite_turf(src,target_turf, release_all = TRUE)
		qdel(ptank)
		return 1 //It hit the flamethrower, not them


/obj/item/assembly/igniter/proc/flamethrower_process(turf/open/location)
	location.hotspot_expose(700,2)

/obj/item/assembly/igniter/proc/ignite_turf(obj/item/flamethrower/F, turf/open/location, release_all = FALSE)
	return F.default_ignite(location, release_all)

///////////////////// Flamethrower as an energy weapon /////////////////////
// Currently used exclusively in /obj/item/gun/energy/printer/flamethrower
/obj/item/ammo_casing/energy/flamethrower
	projectile_type = /obj/item/projectile/bullet/incendiary/flamethrower
	select_name = "fire"
	fire_sound = null
	firing_effect_type = null
	e_cost = 50

/obj/item/projectile/bullet/incendiary/flamethrower
	name = "waft of flames"
	icon_state = null
	damage = 0
	sharpness = SHARP_NONE
	range = 6
	penetration_type = 2
