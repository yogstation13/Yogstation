/obj/effect/anomaly/walterverse//Monkey Anomaly (Random Chimp Event)
	name = "Walter Anomaly"
	desc = "An anomaly that summons Walters from all throughout the walterverse"
	icon_state = "dimensional_overlay"
	lifespan = 20 SECONDS
	var/active = TRUE
	var/list/walter_spawns = list(
		/mob/living/basic/pet/dog/bullterrier/walter/saulter = 5,
		/mob/living/basic/pet/dog/bullterrier/walter/negative = 5,
		/mob/living/basic/pet/dog/bullterrier/walter/syndicate = 5,
		/mob/living/basic/pet/dog/bullterrier/walter/doom = 5,
		/mob/living/basic/pet/dog/bullterrier/walter/space = 5,
		/mob/living/basic/pet/dog/bullterrier/walter/clown = 5,
		/mob/living/basic/pet/dog/bullterrier/walter/french = 5,
		/mob/living/basic/pet/dog/bullterrier/walter/british = 5,
		/mob/living/basic/pet/dog/bullterrier/walter/wizard = 5,
		/mob/living/basic/pet/dog/bullterrier/walter/smallter = 5,
		/mob/living/basic/pet/dog/bullterrier/walter/sus = 1)

/obj/effect/anomaly/walterverse/anomalyEffect(seconds_per_tick)
	..()

	if(isspaceturf(src) || !isopenturf(get_turf(src)))
		return

	if(active)
		active = FALSE
		var/selected_spawn = pick_weight(walter_spawns)
		new selected_spawn(src.loc)
		return
	active = TRUE

/obj/effect/anomaly/walterverse/detonate()
	if(prob(10))
		new /mob/living/basic/pet/dog/bullterrier/walter(src.loc)
