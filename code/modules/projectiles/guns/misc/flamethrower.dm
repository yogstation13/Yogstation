/// How many joules of energy from reactions required to cause 1 damage
#define JOULES_PER_DAMAGE 100000

/obj/item/gun/flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'yogstation/icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamethrower_0"
	lefthand_file = 'icons/mob/inhands/weapons/flamethrower_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/flamethrower_righthand.dmi'
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	materials = list(/datum/material/iron=500)
	resistance_flags = FIRE_PROOF
	item_flags = NONE

	light_range = 2
	light_on = FALSE
	light_system = MOVABLE_LIGHT
	light_color = LIGHT_COLOR_FIRE

	no_pin_required = TRUE
	dry_fire_sound = 'sound/weapons/flamethrower_empty.ogg'
	fire_sound = 'sound/weapons/flamethrower1.ogg'

	var/lit = FALSE	//on or off
	var/acti_sound = 'sound/items/welderactivate.ogg'
	var/deac_sound = 'sound/items/welderdeactivate.ogg'
	var/ammo_type = /obj/item/ammo_casing/flamethrower

	var/obj/item/weldingtool/weldtool = /obj/item/weldingtool
	var/obj/item/assembly/igniter/igniter = /obj/item/assembly/igniter
	var/obj/item/tank/internals/plasma/fuel_tank = null
	//var/list/flame_sounds = list('sound/weapons/flamethrower1.ogg','sound/weapons/flamethrower2.ogg','sound/weapons/flamethrower3.ogg')

/obj/item/gun/flamethrower/full
	fuel_tank = /obj/item/tank/internals/plasma/full

/obj/item/gun/flamethrower/Initialize(mapload)
	. = ..()
	if(weldtool)
		weldtool = new weldtool(src)
	if(igniter)
		igniter = new igniter(src)
	if(fuel_tank)
		fuel_tank = new fuel_tank(src)
	update_appearance(UPDATE_ICON)

/obj/item/gun/flamethrower/CheckParts(list/parts_list)
	. = ..()
	if(weldtool)
		QDEL_NULL(weldtool)
	if(igniter)
		QDEL_NULL(igniter)
	weldtool = locate(/obj/item/weldingtool) in contents
	igniter = locate(/obj/item/assembly/igniter) in contents
	update_appearance(UPDATE_ICON)

/obj/item/gun/flamethrower/Destroy()
	if(weldtool)
		qdel(weldtool)
	if(igniter)
		qdel(igniter)
	if(fuel_tank)
		qdel(fuel_tank)
	return ..()

/obj/item/gun/flamethrower/process()
	if(!lit || !igniter)
		return PROCESS_KILL
	open_flame(igniter.heat)

/obj/item/gun/flamethrower/update_icon_state()
	item_state = "flamethrower_[lit]"
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()
	return ..()

/obj/item/gun/flamethrower/update_overlays()
	. = ..()
	if(igniter)
		. += "+igniter1"
	if(fuel_tank)
		. += "+ptank"
	if(lit)
		. += "+lit"

/obj/item/gun/flamethrower/examine(mob/user)
	. = ..()
	if(fuel_tank)
		. += span_notice("\The [src] has \a [fuel_tank] attached. Right-click to remove it.")

/obj/item/gun/flamethrower/wrench_act(mob/living/user, obj/item/tool, modifiers)
	var/turf/drop_turf = get_turf(src)
	if(weldtool)
		weldtool.forceMove(drop_turf)
		weldtool = null
	if(igniter)
		igniter.forceMove(drop_turf)
		igniter = null
	if(fuel_tank)
		fuel_tank.forceMove(drop_turf)
		fuel_tank = null
	new /obj/item/stack/rods(drop_turf)
	qdel(src)
	return TRUE

/obj/item/gun/flamethrower/attackby(obj/item/weapon, mob/living/user, params)
	if(istype(weapon, /obj/item/tank/internals/plasma))
		if(!user.transferItemToLoc(weapon, src))
			to_chat(user, "[src] is stuck to your hand!")
			return
		if(fuel_tank)
			to_chat(user, "You swap the tank in [src].")
			user.put_in_active_hand(weapon)
		fuel_tank = weapon
		if(chambered)
			QDEL_NULL(chambered)
		update_appearance(UPDATE_ICON)
		return TRUE
	return ..()

/obj/item/gun/flamethrower/return_analyzable_air()
	if(fuel_tank)
		return fuel_tank.return_analyzable_air()
	else
		return null

/obj/item/gun/flamethrower/attack_self(mob/user)
	toggle_igniter(user)

/obj/item/gun/flamethrower/attack_hand_secondary(mob/user, modifiers)
	remove_tank(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/gun/flamethrower/AltClick(mob/user)
	if(isliving(user) && user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		remove_tank(user)
		return
	return ..()

/obj/item/gun/flamethrower/proc/remove_tank(mob/user)
	if(!fuel_tank)
		return
	user.put_in_hands(fuel_tank)
	fuel_tank = null
	if(chambered)
		QDEL_NULL(chambered)
	to_chat(user, span_notice("You remove the plasma tank from [src]."))
	update_appearance(UPDATE_ICON)

/obj/item/gun/flamethrower/proc/toggle_igniter(mob/user)
	if(!fuel_tank)
		to_chat(user, span_notice("Attach a plasma tank first!"))
		return
	to_chat(user, span_notice("You [lit ? "extinguish" : "ignite"] [src]!"))
	lit = !lit
	if(lit)
		playsound(loc, acti_sound, 50, TRUE)
		START_PROCESSING(SSobj, src)
	else
		playsound(loc, deac_sound, 50, TRUE)
		STOP_PROCESSING(SSobj,src)
	set_light_on(lit)
	update_appearance(UPDATE_ICON)

/obj/item/gun/flamethrower/can_shoot()
	return (igniter && fuel_tank?.air_contents?.return_pressure())

/obj/item/gun/flamethrower/recharge_newshot()
	chambered = new ammo_type(src)
	chambered.newshot()

/obj/item/gun/flamethrower/process_chamber()
	if(chambered)
		QDEL_NULL(chambered)
	recharge_newshot()

/obj/item/gun/flamethrower/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread, cd_override)
	if(!chambered && can_shoot())
		process_chamber()
	return ..()

/obj/item/gun/flamethrower/process_burst(mob/living/user, atom/target, message, params, zone_override, sprd, randomized_gun_spread, randomized_bonus_spread, rand_spr, iteration)
	if(!chambered && can_shoot())
		process_chamber()
	return ..()

/obj/item/gun/flamethrower/shoot_with_empty_chamber(mob/living/user)
	. = ..()
	if(lit)
		lit = FALSE
		visible_message(span_danger("\The [src] breathes a sighed hiss as its flame dies out."))
		set_light_on(FALSE)
		STOP_PROCESSING(SSobj,src)
		update_appearance(UPDATE_ICON)

/obj/item/ammo_casing/flamethrower
	name = "flamethrower fuel"
	desc = "If you see this, yell at Sarah."
	projectile_type = /obj/projectile/flamethrower
	firing_effect_type = null

/obj/item/ammo_casing/energy/flame_projector // cyborg flame projector
	projectile_type = /obj/projectile/flamethrower/weak
	select_name = "fire"
	fire_sound = 'sound/weapons/flamethrower1.ogg'
	firing_effect_type = null
	e_cost = 50

/obj/projectile/flamethrower
	name = "\proper fire"
	desc = "Yep, that's fire."
	icon_state = null // the actual fire will handle it
	armor_flag = FIRE
	damage_type = BURN
	sharpness = SHARP_NONE
	hitsound = null
	range = 6
	damage = 16
	demolition_mod = 2 // bonus damage against blobs and vines, most other structures have very high fire armor
	penetration_flags = PENETRATE_OBJECTS|PENETRATE_MOBS
	penetrations = INFINITY
	ignore_crit = TRUE
	///Reference to the fuel tank in the flamethrower.
	var/obj/item/tank/fuel_tank
	///Temperature of the flamethrower's igniter.
	var/igniter_temp = 1000
	///Temperature of the fuel's most recent burn reaction, used for damaging mobs/mechs
	var/last_burn_temp = 1000

/obj/projectile/flamethrower/weak
	nodamage = TRUE

/obj/projectile/flamethrower/fire(angle, atom/direct_target)
	if(istype(fired_from, /obj/item/gun/flamethrower))
		var/obj/item/gun/flamethrower/flamer = fired_from
		fuel_tank = flamer.fuel_tank
		igniter_temp = flamer.igniter.heat
		last_burn_temp = igniter_temp
	return ..()

/obj/projectile/flamethrower/Move(atom/newloc, dir)
	. = ..()
	if(!process_fuel(newloc))
		qdel(src)
	var/turf/target_turf = get_turf(newloc)
	target_turf.ignite_turf(rand(damage, damage * 4))
	new /obj/effect/hotspot(target_turf, CELL_VOLUME, igniter_temp)

/obj/projectile/flamethrower/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	var/turf/new_turf = get_turf(loc)
	var/turf/old_turf = get_turf(old_loc)
	if(!TURFS_CAN_SHARE(new_turf, old_turf))
		qdel(src)

/obj/projectile/flamethrower/prehit(atom/target) // humans use a different heat protection system
	if(nodamage)
		return FALSE // don't do direct damage, just make fire
	if(ishuman(target))
		var/mob/living/carbon/human/joshua_graham = target
		joshua_graham.apply_damage(damage, BURN, null, joshua_graham.get_heat_protection(last_burn_temp) * 100)
		return FALSE // already did the damage
	return TRUE

/obj/projectile/flamethrower/proc/process_fuel(atom/target, release_all = FALSE)
	if(!fuel_tank)
		return TRUE
	if(QDELETED(fuel_tank))
		return FALSE
	if(!fuel_tank.air_contents?.return_pressure())
		return FALSE

	var/ratio_removed = min(fuel_tank.distribute_pressure, fuel_tank.air_contents.return_pressure()) / fuel_tank.air_contents.return_pressure()

	var/datum/gas_mixture/fuel_mix = fuel_tank.air_contents.remove_ratio(ratio_removed)
	var/datum/gas_mixture/turf_mix = target.return_air()

	fuel_mix.merge(turf_mix.copy()) // copy air from the turf to do reactions with
	fuel_mix.set_temperature(igniter_temp) // heat the contents

	var/old_thermal_energy = fuel_mix.thermal_energy()
	for(var/i in 1 to 10) // react a bunch of times on the target turf
		if(!fuel_mix.react(target))
			break // break the loop if it stops reacting

	// damage is based on the positive or negative energy of the reaction, capped at its original value
	damage = min(abs(fuel_mix.thermal_energy() - old_thermal_energy) / JOULES_PER_DAMAGE, initial(damage))
	last_burn_temp = fuel_mix.return_temperature()

	// If there's not enough fuel and/or oxygen to do more than 1 damage, shut itself off
	if(damage < 1)
		return FALSE
	return damage

#undef JOULES_PER_DAMAGE
