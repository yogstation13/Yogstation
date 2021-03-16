/datum/component/rot
	var/amount = 1

/datum/component/rot/Initialize(new_amount)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	if(new_amount)
		amount = new_amount

	START_PROCESSING(SSprocessing, src)

/datum/component/rot/process()
	var/atom/A = parent

	var/turf/open/T = get_turf(A)
	if(!istype(T) || T.return_air().return_pressure() > (WARNING_HIGH_PRESSURE - 10))
		return
	var/area/area = get_area(T)
	if(area.outdoors)
		return

	var/datum/gas_mixture/turf_air = T.return_air()
	var/datum/gas_mixture/stank_breath = T.remove_air(1 / turf_air.return_volume() * turf_air.total_moles())
	if(!stank_breath)
		return
	stank_breath.set_volume(1)
	var/oxygen_pp = stank_breath.get_moles(/datum/gas/oxygen) * R_IDEAL_GAS_EQUATION * stank_breath.return_temperature() / stank_breath.return_volume()
	
	if(oxygen_pp > 18)
		var/this_amount = min((oxygen_pp - 8) * stank_breath.return_volume() / stank_breath.return_temperature() / R_IDEAL_GAS_EQUATION, amount)
		stank_breath.adjust_moles(/datum/gas/oxygen, -this_amount)

		var/datum/gas_mixture/stank = new
		stank.set_moles(/datum/gas/miasma, this_amount)
		stank.set_temperature(BODYTEMP_NORMAL) // otherwise we have gas below 2.7K which will break our lag generator
		stank_breath.merge(stank)
	T.assume_air(stank_breath)
	T.air_update_turf()

/datum/component/rot/corpse
	amount = MIASMA_CORPSE_MOLES

/datum/component/rot/corpse/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()

/datum/component/rot/corpse/process()
	var/mob/living/carbon/C = parent
	if(C.stat != DEAD)
		qdel(src)
		return

	// Wait a bit before decaying
	if(world.time - C.timeofdeath < 2 MINUTES)
		return

	// Properly stored corpses shouldn't create miasma
	if(istype(C.loc, /obj/structure/closet/crate/coffin)|| istype(C.loc, /obj/structure/closet/body_bag) || istype(C.loc, /obj/structure/bodycontainer))
		return

	// No decay if formaldehyde in corpse or when the corpse is charred
	if(C.reagents.has_reagent(/datum/reagent/toxin/formaldehyde, 15) || HAS_TRAIT(C, TRAIT_HUSK))
		return

	// Also no decay if corpse chilled or not organic/undead
	if(C.bodytemperature <= T0C-10 || (!(MOB_ORGANIC in C.mob_biotypes) && !(MOB_UNDEAD in C.mob_biotypes)))
		return

	..()

/datum/component/rot/gibs
	amount = MIASMA_GIBS_MOLES
