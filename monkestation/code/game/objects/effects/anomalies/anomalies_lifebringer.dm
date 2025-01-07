/obj/effect/anomaly/lifebringer //2catz lmao (also see thermonuclear catsplosion)
	name = "Lifebringer Anomaly"
	desc = "An anomalous gateway that seemingly creates new life out of nowhere. Known by Lavaland Dwarves as the \"Petsplosion\"."
	icon_state = "bluestream_fade"
	lifespan = 30 SECONDS
	var/active = TRUE
	var/list/pet_type_cache
	var/catsplosion = FALSE

/obj/effect/anomaly/lifebringer/Initialize(mapload, new_lifespan)
	. = ..()
	if(prob(1))
		catsplosion = TRUE

	pet_type_cache = subtypesof(/mob/living/basic/pet)
	pet_type_cache += list(
		/mob/living/basic/axolotl,
		/mob/living/basic/butterfly,
		/mob/living/basic/cockroach,
		/mob/living/basic/crab,
		/mob/living/basic/frog,
		/mob/living/basic/lizard,
		/mob/living/basic/mothroach,
		/mob/living/basic/bat,
		/mob/living/basic/parrot,
		/mob/living/basic/chicken,
		/mob/living/basic/sloth)
	pet_type_cache -= list(/mob/living/basic/pet/penguin, //Removing the risky and broken ones.
		/mob/living/basic/pet/dog/corgi/narsie,
		/mob/living/basic/pet/dog,
		/mob/living/basic/pet/fox
		)

/obj/effect/anomaly/lifebringer/anomalyEffect(seconds_per_tick)
	..()

	if(isspaceturf(src) || !isopenturf(get_turf(src)))
		return
	if(active)

		if(catsplosion)
			new /mob/living/basic/pet/cat(src.loc)
			active = FALSE
			var/turf/open/tile = get_turf(src)
			if(istype(tile))
				tile.atmos_spawn_air("o2=45;plasma=15;TEMP=6000")
			return

		var/mob/living/basic/pet/chosen_pet = pick(pet_type_cache)
		new chosen_pet(src.loc)
		active = FALSE
		return

	active = TRUE
