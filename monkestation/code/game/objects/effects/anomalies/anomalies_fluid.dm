#define NORMAL_FLUID_AMOUNT 25
#define DANGEROUS_FLUID_AMOUNT 100

//fully automated piss floods
/obj/effect/anomaly/fluid
	name = "Fluidic Anomaly"
	desc = "An anomaly pulling in liquids from places unknown. Better get the mop."
	icon_state = "bluestream_fade"
	var/dangerous = FALSE
	var/list/fluid_choices = list()

/obj/effect/anomaly/fluid/Initialize(mapload, new_lifespan)
	. = ..()
	if(prob(10))
		dangerous = TRUE //Unrestricts the reagent choice and increases fluid amounts

	for(var/i = 1, i <= rand(1,5), i++) //Between 1 and 5 random chemicals
		fluid_choices += dangerous ? get_random_reagent_id_unrestricted() : get_random_reagent_id()

/obj/effect/anomaly/fluid/anomalyEffect(seconds_per_tick)
	..()

	if(isspaceturf(src) || !isopenturf(get_turf(src)))
		return

	var/turf/spawn_point = get_turf(src)
	spawn_point.add_liquid(pick(fluid_choices), dangerous ? DANGEROUS_FLUID_AMOUNT : NORMAL_FLUID_AMOUNT, chem_temp = rand(BODYTEMP_COLD_DAMAGE_LIMIT, BODYTEMP_HEAT_DAMAGE_LIMIT))

/obj/effect/anomaly/fluid/detonate()
	if(isinspace(src) || !isopenturf(get_turf(src)))
		return
	var/turf/spawn_point = get_turf(src)
	spawn_point.add_liquid(pick(fluid_choices), (dangerous ? DANGEROUS_FLUID_AMOUNT : NORMAL_FLUID_AMOUNT) * 5, chem_temp = rand(BODYTEMP_COLD_DAMAGE_LIMIT, BODYTEMP_HEAT_DAMAGE_LIMIT))

#undef NORMAL_FLUID_AMOUNT
#undef DANGEROUS_FLUID_AMOUNT
