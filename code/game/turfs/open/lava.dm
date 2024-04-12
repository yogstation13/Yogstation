///LAVA

/turf/open/lava
	name = "lava"
	icon_state = "lava"
	desc = "Looks painful to step in. Don't mine down."
	gender = PLURAL //"That's some lava."
	baseturfs = /turf/open/lava //lava all the way down
	slowdown = 2

	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA
	light_on = FALSE
	bullet_bounce_sound = 'sound/items/welder2.ogg'

	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA

	/// The icon that covers the lava bits of our turf
	var/mask_icon = 'icons/turf/floors.dmi'
	/// The icon state that covers the lava bits of our turf
	var/mask_state = "lava-lightmask"
	/// The temperature this lava will heat or cool radiator pipes to
	var/lava_temperature = 5000
	/// The heat capacity of the lava, used by heat exchange pipes
	var/lava_heat_capacity = 700000

/turf/open/lava/Initialize(mapload)
	. = ..()
	refresh_light()
	if(!smoothing_flags)
		update_appearance()
	AddComponent(/datum/component/fishable/lava)

/turf/open/lava/update_overlays()
	. = ..()
	. += emissive_appearance(mask_icon, mask_state, src)
	// We need a light overlay here because not every lava turf casts light, only the edge ones
	var/mutable_appearance/light = mutable_appearance(mask_icon, mask_state, LIGHTING_PRIMARY_LAYER, src, LIGHTING_PLANE)
	light.color = light_color
	light.blend_mode = BLEND_ADD
	. += light
	// Mask away our light underlay, so things don't double stack
	// This does mean if our light underlay DOESN'T look like the light we emit things will be wrong
	// But that's rare, and I'm ok with that, quartering our light source count is useful
	var/mutable_appearance/light_mask = mutable_appearance(mask_icon, mask_state, LIGHTING_MASK_LAYER, src, LIGHTING_PLANE)
	light_mask.blend_mode = BLEND_MULTIPLY
	light_mask.color = COLOR_MATRIX_INVERT
	. += light_mask

/// Refreshes this lava turf's lighting
/turf/open/lava/proc/refresh_light()
	var/border_turf = FALSE
	var/list/turfs_to_check = RANGE_TURFS(1, src)
	if(GET_LOWEST_STACK_OFFSET(z))
		var/turf/above = GET_TURF_ABOVE(src)
		if(above)
			turfs_to_check += RANGE_TURFS(1, above)
		var/turf/below = GET_TURF_BELOW(src)
		if(below)
			turfs_to_check += RANGE_TURFS(1, below)

	for(var/turf/around as anything in turfs_to_check)
		if(islava(around))
			continue
		border_turf = TRUE

	if(!border_turf)
		set_light(l_on = FALSE)
		return

	set_light(l_on = TRUE)

/turf/open/lava/ChangeTurf(path, list/new_baseturfs, flags)
	var/turf/result = ..()

	if(result && !islava(result))
		// We have gone from a lava turf to a non lava turf, time to let them know
		var/list/turfs_to_check = RANGE_TURFS(1, result)
		if(GET_LOWEST_STACK_OFFSET(z))
			var/turf/above = GET_TURF_ABOVE(result)
			if(above)
				turfs_to_check += RANGE_TURFS(1, above)
			var/turf/below = GET_TURF_BELOW(result)
			if(below)
				turfs_to_check += RANGE_TURFS(1, below)
		for(var/turf/open/lava/inform in turfs_to_check)
			inform.set_light(l_on = TRUE)

	return result

/turf/open/lava/smooth_icon()
	. = ..()
	mask_state = icon_state
	update_appearance(~UPDATE_SMOOTHING)

/turf/open/lava/ex_act(severity, target)
	contents_explosion(severity, target)

/turf/open/lava/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/lava/acid_act(acidpwr, acid_volume)
	return

/turf/open/lava/MakeDry(wet_setting = TURF_WET_WATER)
	return

/turf/open/lava/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/lava/Entered(atom/movable/AM)
	if(burn_stuff(AM))
		START_PROCESSING(SSobj, src)

/turf/open/lava/Exited(atom/movable/Obj, atom/newloc)
	. = ..()
	if(isliving(Obj))
		var/mob/living/L = Obj
		if(!islava(newloc) && !L.on_fire)
			L.update_fire()

/turf/open/lava/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(burn_stuff(AM))
		START_PROCESSING(SSobj, src)

/turf/open/lava/process(delta_time)
	if(!burn_stuff(null, delta_time))
		STOP_PROCESSING(SSobj, src)

/turf/open/lava/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.construction_mode)
		if(RCD_FLOORWALL)
			return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 3)
	return FALSE

/turf/open/lava/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, span_notice("You build a floor."))
			place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return TRUE
	return FALSE

/turf/open/lava/rust_heretic_act()
	return FALSE
	
/turf/open/lava/singularity_act()
	return

/turf/open/lava/singularity_pull(S, current_size)
	return

/turf/open/lava/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/open/lava/GetHeatCapacity()
	return lava_heat_capacity

/turf/open/lava/GetTemperature()
	return lava_temperature

/turf/open/lava/TakeTemperature(temp)


/turf/open/lava/proc/is_safe()
	//if anything matching this typecache is found in the lava, we don't burn things
	var/static/list/lava_safeties_typecache = typecacheof(list(/obj/structure/lattice/catwalk, /obj/structure/stone_tile))
	var/list/found_safeties = typecache_filter_list(contents, lava_safeties_typecache)
	for(var/obj/structure/stone_tile/S in found_safeties)
		if(S.fallen)
			LAZYREMOVE(found_safeties, S)
	return LAZYLEN(found_safeties)


/turf/open/lava/proc/burn_stuff(AM, delta_time = 1)
	. = 0

	if(is_safe())
		return FALSE

	var/thing_to_check = src
	if (AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(isobj(thing))
			var/obj/O = thing
			if((O.resistance_flags & (LAVA_PROOF|INDESTRUCTIBLE)) || O.throwing)
				continue
			. = 1
			if((O.resistance_flags & (ON_FIRE)))
				continue
			if(!(O.resistance_flags & FLAMMABLE))
				O.resistance_flags |= FLAMMABLE //Even fireproof things burn up in lava
			if(O.resistance_flags & FIRE_PROOF)
				O.resistance_flags &= ~FIRE_PROOF
			if(O.armor.fire > 50) //obj with 100% fire armor still get slowly burned away.
				O.armor = O.armor.setRating(fire = 50)
			O.fire_act(10000, 1000 * delta_time)

		else if (isliving(thing))
			. = 1
			var/mob/living/L = thing
			if(L.movement_type & FLYING)
				continue	//YOU'RE FLYING OVER IT
			var/buckle_check = L.buckling
			if(!buckle_check)
				buckle_check = L.buckled
			if(isobj(buckle_check))
				var/obj/O = buckle_check
				if(O.resistance_flags & LAVA_PROOF)
					continue
			else if(isliving(buckle_check))
				var/mob/living/live = buckle_check
				if("lava" in live.weather_immunities)
					continue

			if(!L.on_fire)
				L.update_fire()

			if(iscarbon(L))
				var/mob/living/carbon/C = L
				var/obj/item/clothing/S = C.get_item_by_slot(ITEM_SLOT_OCLOTHING)
				var/obj/item/clothing/H = C.get_item_by_slot(ITEM_SLOT_HEAD)

				if(S && H && S.clothing_flags & LAVAPROTECT && H.clothing_flags & LAVAPROTECT)
					return

			if("lava" in L.weather_immunities)
				continue

			L.adjustFireLoss(20 * delta_time)
			if(L) //mobs turning into object corpses could get deleted here.
				L.adjust_fire_stacks(20 * delta_time)
				L.ignite_mob()

/turf/open/lava/smooth
	name = "lava"
	baseturfs = /turf/open/lava/smooth
	icon = 'icons/turf/floors/lava.dmi'
	mask_icon = 'icons/turf/floors/lava_mask.dmi'
	icon_state = "lava-255"
	mask_state = "lava-255"
	base_icon_state = "lava"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_LAVA
	canSmoothWith = SMOOTH_GROUP_FLOOR_LAVA

/turf/open/lava/smooth/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/lava_land_surface

/turf/open/lava/smooth/lava_land_surface/no_shelter //snowflake version that survival pods won't spawn in

/turf/open/lava/smooth/airless
	initial_gas_mix = AIRLESS_ATMOS
