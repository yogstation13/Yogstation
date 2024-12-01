#define HONK_RANGE 3
//clwun nomaly honk
/obj/effect/anomaly/clown
	name = "Honking Anomaly"
	icon_state = "static"
	desc = "An anomaly that smells faintly of bananas and lubricant."
	color = "#86c4dd"
	lifespan = 40 SECONDS //fast and slippery
	var/active = TRUE
	var/list/comedysounds = list('sound/items/SitcomLaugh1.ogg', 'sound/items/SitcomLaugh2.ogg', 'sound/items/SitcomLaugh3.ogg')
	var/static/list/clown_spawns = list(
		/mob/living/basic/clown/clownhulk/chlown = 6,
		/mob/living/basic/clown = 66,
		/obj/item/grown/bananapeel = 33,
		/obj/item/stack/ore/bananium = 12,
		/obj/item/bikehorn = 15)

/obj/effect/anomaly/clown/Initialize(mapload, new_lifespan)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/anomaly/clown/Destroy()
	. = ..()
	RemoveElement(/datum/element/connect_loc)

/obj/effect/anomaly/clown/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER

	if(active && iscarbon(atom_movable))
		var/mob/living/carbon/target = atom_movable
		active = FALSE
		target.slip(4 SECONDS, src)
		playsound(src, pick(comedysounds), vol = 50, vary = 1)

/obj/effect/anomaly/clown/anomalyEffect(seconds_per_tick)
	..()

	if(isspaceturf(src) || !isopenturf(get_turf(src)))
		return

	var/turf/open/current_location = get_turf(src)
	current_location.MakeSlippery(TURF_WET_LUBE, min_wet_time = 20 SECONDS, wet_time_to_add = 5 SECONDS)
	if(active)
		active = FALSE
		playsound(src, 'sound/items/bikehorn.ogg', vol = 50)
		var/selected_spawn = pick_weight(clown_spawns)
		new selected_spawn(src.loc)
		return
	active = TRUE

/obj/effect/anomaly/clown/detonate()
	playsound(src, 'sound/items/airhorn.ogg', vol = 100, vary = 1)

	for(var/mob/living/carbon/target in (hearers(HONK_RANGE, src)))
		to_chat(target, "<font color='red' size='10'>HONK</font>")
		target.SetSleeping(0)
		target.adjust_stutter(10 SECONDS)
		var/obj/item/organ/internal/ears/ears = target.get_organ_slot(ORGAN_SLOT_EARS)
		ears?.adjustEarDamage(0, 2 SECONDS)
		target.Knockdown(2 SECONDS)
		target.set_jitter_if_lower(50 SECONDS)

#undef HONK_RANGE
